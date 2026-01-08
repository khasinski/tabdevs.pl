module Editable
  extend ActiveSupport::Concern

  def editable?
    created_at > SiteSetting.get(:edit_grace_period_minutes, 15).to_i.minutes.ago
  end

  def can_be_edited_by?(user)
    return false unless user
    return true if user.admin? || user.moderator?
    author == user && editable?
  end

  def edited?
    edited_at.present?
  end

  def mark_as_edited!
    update_column(:edited_at, Time.current) unless edited?
  end
end
