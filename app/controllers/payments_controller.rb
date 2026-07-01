class PaymentsController < ApplicationController
  def refund
    @payment = Payment.joins(:booking_link)
                      .where(booking_links: { user_id: current_user.id })
                      .find(params[:id])

    unless @payment.refundable?
      redirect_to dashboard_path, alert: "Payment cannot be refunded."
      return
    end

    stripe_account = @payment.booking_link.user.stripe_account_id

    Stripe::Refund.create(
      { payment_intent: @payment.stripe_payment_intent_id, refund_application_fee: true },
      { stripe_account: stripe_account }
    )

    @payment.update!(status: "refunded", refunded_at: Time.current)
    redirect_to dashboard_path, notice: "Deposit refunded."
  rescue Stripe::StripeError => e
    redirect_to dashboard_path, alert: "Refund failed: #{e.message}"
  end
end
