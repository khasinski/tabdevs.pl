class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  DEFAULTS = {
    downvote_threshold: 0,
    new_user_post_limit: 2,
    new_user_comment_limit: 10,
    new_user_period_hours: 24,
    posts_per_day_limit: 5,
    comments_per_hour_limit: 30,
    votes_per_hour_limit: 100,
    magic_link_expiry_minutes: 15,
    edit_grace_period_minutes: 15,
    duplicate_url_days: 365
  }.freeze

  def self.get(key, default = nil)
    setting = find_by(key: key.to_s)
    setting&.value || default || DEFAULTS[key.to_sym]
  end

  def self.set(key, value)
    setting = find_or_initialize_by(key: key.to_s)
    setting.update!(value: value.to_s)
  end

  def self.all_settings
    DEFAULTS.keys.index_with { |key| get(key) }
  end
end
