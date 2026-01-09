module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def upvote!(user)
    vote_with_value!(user, 1)
  end

  def downvote!(user)
    return false unless user.can_downvote?
    vote_with_value!(user, -1)
  end

  def remove_vote!(user)
    vote = votes.find_by(user: user)
    return false unless vote

    transaction do
      decrement!(:score, vote.value)
      update_author_karma(-vote.value, user)
      vote.destroy!
    end
    true
  end

  def user_vote(user)
    votes.find_by(user: user)&.value
  end

  private

  def vote_with_value!(user, value)
    existing = votes.find_by(user: user)

    transaction do
      if existing
        old_value = existing.value
        decrement!(:score, old_value)
        update_author_karma(-old_value, user)
        existing.update!(value: value)
      else
        votes.create!(user: user, value: value)
      end
      increment!(:score, value)
      update_author_karma(value, user)
    end
    true
  end

  def update_author_karma(change, voter)
    return if author == voter
    return if change.zero?

    author.increment!(:karma, change)
  end
end
