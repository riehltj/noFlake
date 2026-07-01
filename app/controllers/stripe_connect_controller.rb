class StripeConnectController < ApplicationController
  def connect
    account_id = current_user.stripe_account_id ||
                 session[:pending_stripe_account_id] ||
                 Stripe::Account.create(
                   type: "express",
                   capabilities: {
                     card_payments: { requested: true },
                     transfers:     { requested: true }
                   }
                 ).id

    session[:pending_stripe_account_id] = account_id unless current_user.stripe_account_id

    account_link = Stripe::AccountLink.create(
      account:     account_id,
      refresh_url: stripe_connect_url,
      return_url:  stripe_return_url,
      type:        "account_onboarding"
    )

    redirect_to account_link.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to dashboard_path, alert: "Stripe error: #{e.message}"
  end

  def onboarding_return
    account_id = session.delete(:pending_stripe_account_id) || current_user.stripe_account_id

    unless account_id
      redirect_to dashboard_path, alert: "Something went wrong. Please try connecting again."
      return
    end

    account = Stripe::Account.retrieve(account_id)

    if account.charges_enabled
      current_user.update!(stripe_account_id: account_id)
      redirect_to dashboard_path, notice: "Stripe account connected!"
    else
      redirect_to dashboard_path, alert: "Stripe onboarding incomplete. Please try connecting again."
    end
  rescue Stripe::StripeError => e
    redirect_to dashboard_path, alert: "Stripe error: #{e.message}"
  end
end
