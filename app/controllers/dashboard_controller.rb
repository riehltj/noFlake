class DashboardController < ApplicationController
  def index
    @booking_links = current_user.booking_links.order(created_at: :desc)
    @payments = Payment.includes(:booking_link)
                       .joins(:booking_link)
                       .where(booking_links: { user_id: current_user.id })
                       .order(created_at: :desc)
  end
end
