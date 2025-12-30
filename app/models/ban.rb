class Ban < ApplicationRecord
  belongs_to :user
  belongs_to :moderator, class_name: "User"

  enum :ban_type, { soft: 0, hard: 1 }

  validates :reason, presence: true

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }

  def active?
    expires_at.nil? || expires_at > Time.current
  end

  def permanent?
    expires_at.nil?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def remaining_time
    return nil if permanent?
    return nil if expired?
    expires_at - Time.current
  end
end
