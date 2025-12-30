class MagicLink < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expiry, on: :create

  scope :valid, -> { where(used_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def used?
    used_at.present?
  end

  def valid_for_use?
    !expired? && !used?
  end

  def use!
    return false unless valid_for_use?
    update!(used_at: Time.current)
  end

  def self.find_and_use(token)
    link = valid.find_by(token: token)
    return nil unless link
    link.use! ? link : nil
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    self.expires_at ||= SiteSetting.get(:magic_link_expiry_minutes, 15).to_i.minutes.from_now
  end
end
