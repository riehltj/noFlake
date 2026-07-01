class Payment < ApplicationRecord
  belongs_to :booking_link

  scope :paid, -> { where(status: "paid") }
  scope :refunded, -> { where(status: "refunded") }

  def refundable?
    status == "paid"
  end
end
