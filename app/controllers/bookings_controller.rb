class BookingsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @booking_link = find_booking_link!
  end

  def checkout
    @booking_link = find_booking_link!
    owner = @booking_link.user

    unless owner.stripe_connected?
      redirect_to booking_path(owner.slug, @booking_link.slug), alert: "This booking link is not active yet."
      return
    end

    session = Stripe::Checkout::Session.create(
      {
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency:     "usd",
            unit_amount:  @booking_link.deposit_cents,
            product_data: { name: "Hold – #{@booking_link.service_name}" }
          },
          quantity: 1
        }],
        mode:        "payment",
        payment_intent_data: {
          application_fee_amount: (@booking_link.deposit_cents * 0.01).round
        },
        success_url: booking_success_url(slug: @booking_link.slug) + "&session_id={CHECKOUT_SESSION_ID}",
        cancel_url:  booking_url(owner.slug, @booking_link.slug),
        metadata:    { booking_link_id: @booking_link.id }
      },
      { stripe_account: owner.stripe_account_id }
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    @booking_link = BookingLink.find_by(slug: params[:slug])
    return unless @booking_link && params[:session_id].present?

    stripe_session = Stripe::Checkout::Session.retrieve(
      params[:session_id],
      { stripe_account: @booking_link.user.stripe_account_id }
    )

    if stripe_session.payment_status == "paid"
      Payment.find_or_create_by!(stripe_payment_intent_id: stripe_session.payment_intent) do |p|
        p.booking_link   = @booking_link
        p.amount_cents   = stripe_session.amount_total
        p.customer_email = stripe_session.customer_details&.email
        p.status         = "paid"
      end
    end
  rescue Stripe::StripeError
    nil
  end

  private

  def find_booking_link!
    booking_link = BookingLink.find_by!(slug: params[:slug])
    raise ActiveRecord::RecordNotFound unless booking_link.user.slug == params[:business_slug]

    booking_link
  end
end
