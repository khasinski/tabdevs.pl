class User < ApplicationRecord
  has_secure_password validations: false

  has_many :magic_links, dependent: :destroy
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_many :comments, foreign_key: :author_id, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :bans, dependent: :destroy
  has_many :moderated_items, class_name: "ModerationItem", foreign_key: :moderator_id
  has_many :moderated_bans, class_name: "Ban", foreign_key: :moderator_id

  enum :role, { user: 0, moderator: 1, admin: 2 }
  enum :status, { active: 0, suspended: 1, banned: 2 }

  validates :username, presence: true, uniqueness: true, length: { in: 3..30 },
            format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "może zawierać tylko litery, cyfry, _ i -" }
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :normalize_email

  def bot?
    username == "tabdevs-bot"
  end

  def has_password?
    password_digest.present?
  end

  def voted_for?(votable)
    votes.exists?(votable: votable)
  end

  def can_downvote?
    karma >= SiteSetting.get(:downvote_threshold, 0).to_i
  end

  def can_post?
    return false if banned?
    return false if suspended?

    if new_user?
      posts.where("created_at > ?", 24.hours.ago).count < SiteSetting.get(:new_user_post_limit, 2).to_i
    else
      posts.where("created_at > ?", 24.hours.ago).count < SiteSetting.get(:posts_per_day_limit, 5).to_i
    end
  end

  def can_comment?
    return false if banned?
    return false if suspended?

    if new_user?
      comments.where("created_at > ?", 1.hour.ago).count < SiteSetting.get(:new_user_comment_limit, 10).to_i
    else
      comments.where("created_at > ?", 1.hour.ago).count < SiteSetting.get(:comments_per_hour_limit, 30).to_i
    end
  end

  def new_user?
    created_at > SiteSetting.get(:new_user_period_hours, 24).to_i.hours.ago
  end

  def active_ban
    bans.where("expires_at IS NULL OR expires_at > ?", Time.current).order(created_at: :desc).first
  end

  def recalculate_karma!
    total = posts.sum(:score) + comments.sum(:score)
    update_column(:karma, total)
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
