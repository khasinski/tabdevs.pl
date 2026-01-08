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
        decrement!(:score, existing.value)
        existing.update!(value: value)
      else
        votes.create!(user: user, value: value)
      end
      increment!(:score, value)
    end
    true
  end
end
