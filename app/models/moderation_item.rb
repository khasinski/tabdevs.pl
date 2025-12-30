class ModerationItem < ApplicationRecord
  belongs_to :moderatable, polymorphic: true
  belongs_to :moderator, class_name: "User", optional: true

  enum :reason, { ai_suggested: 0, user_report: 1, duplicate: 2 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  scope :pending_review, -> { where(status: :pending) }

  def approve!(moderator)
    update!(
      status: :approved,
      moderator: moderator,
      resolved_at: Time.current
    )
  end

  def reject!(moderator)
    update!(
      status: :rejected,
      moderator: moderator,
      resolved_at: Time.current
    )
  end
end
