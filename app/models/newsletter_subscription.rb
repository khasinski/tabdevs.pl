class NewsletterSubscription < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :generate_token

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :active, -> { confirmed.where(unsubscribed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def unsubscribed?
    unsubscribed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current) unless confirmed?
  end

  def unsubscribe!
    update!(unsubscribed_at: Time.current) unless unsubscribed?
  end

  def resubscribe!
    update!(unsubscribed_at: nil, confirmed_at: Time.current)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
