class BookingLinksController < ApplicationController
  def index
    redirect_to dashboard_path
  end

  def create
    p = booking_link_params
    attrs = {
      service_name:  p[:service_name],
      deposit_cents: (p[:deposit_dollars].to_f * 100).round,
      price_cents:   p[:price_dollars].present? ? (p[:price_dollars].to_f * 100).round : nil
    }
    @booking_link = current_user.booking_links.build(attrs)
    if @booking_link.save
      redirect_to dashboard_path, notice: "Booking link created!"
    else
      redirect_to dashboard_path, alert: @booking_link.errors.full_messages.to_sentence
    end
  end

  private

  def booking_link_params
    params.require(:booking_link).permit(:service_name, :deposit_dollars, :price_dollars)
  end
end
