class BookingLink < ApplicationRecord
  belongs_to :user
  has_many :payments, dependent: :destroy

  validates :slug, presence: true, uniqueness: true
  validates :service_name, presence: true
  validates :deposit_cents, presence: true, numericality: { greater_than: 0 }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug ||= SecureRandom.alphanumeric(8).downcase
  end
end
