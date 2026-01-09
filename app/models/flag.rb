class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :flaggable, polymorphic: true
  belongs_to :resolved_by, class_name: "User", optional: true

  enum :reason, {
    spam: 0,
    offensive: 1,
    off_topic: 2,
    duplicate: 3,
    misinformation: 4,
    other: 5
  }

  validates :reason, presence: true
  validates :user_id, uniqueness: { scope: [ :flaggable_type, :flaggable_id ], message: "juz zglosiles ta tresc" }
  validates :description, presence: true, if: -> { other? }

  scope :pending, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def resolved?
    resolved_at.present?
  end

  def resolve!(moderator)
    update!(resolved_at: Time.current, resolved_by: moderator)
  end
end
