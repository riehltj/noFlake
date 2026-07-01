class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def stripe
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
      return
    end

    case event["type"]
    when "checkout.session.completed"
      handle_checkout_completed(event["data"]["object"], event["account"])
    end

    head :ok
  end

  private

  def handle_checkout_completed(session, stripe_account_id)
    booking_link_id = session.dig("metadata", "booking_link_id")
    return unless booking_link_id

    booking_link = BookingLink.find_by(id: booking_link_id)
    return unless booking_link

    Payment.find_or_create_by!(stripe_payment_intent_id: session["payment_intent"]) do |p|
      p.booking_link   = booking_link
      p.amount_cents   = session["amount_total"]
      p.customer_email = session.dig("customer_details", "email")
      p.status         = "paid"
    end
  end
end
