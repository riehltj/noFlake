class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :booking_links, dependent: :destroy

  before_validation :downcase_slug

  validates :slug, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: /\A[a-z0-9]+(-[a-z0-9]+)*\z/, message: "can only contain lowercase letters, numbers, and hyphens" },
                    length: { minimum: 3, maximum: 40 }

  def stripe_connected?
    stripe_account_id.present?
  end

  private

  def downcase_slug
    self.slug = slug.downcase if slug.present?
  end
end
