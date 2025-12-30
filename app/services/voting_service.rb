class VotingService
  attr_reader :votable, :user, :error

  def initialize(votable:, user:)
    @votable = votable
    @user = user
    @error = nil
  end

  def upvote!
    vote_with_value!(1)
  end

  def downvote!
    unless user.can_downvote?
      @error = :insufficient_karma
      return false
    end
    vote_with_value!(-1)
  end

  def remove_vote!
    vote = votable.votes.find_by(user: user)
    return false unless vote

    ActiveRecord::Base.transaction do
      votable.decrement!(:score, vote.value)
      vote.destroy!
      update_author_karma(-vote.value)
    end
    true
  end

  private

  def vote_with_value!(value)
    existing = votable.votes.find_by(user: user)

    ActiveRecord::Base.transaction do
      if existing
        old_value = existing.value
        votable.decrement!(:score, old_value)
        existing.update!(value: value)
        update_author_karma(-old_value)
      else
        votable.votes.create!(user: user, value: value)
      end
      votable.increment!(:score, value)
      update_author_karma(value)
    end
    true
  end

  def update_author_karma(change)
    return if votable.author == user
    return if change.zero?

    votable.author.increment!(:karma, change)
  end
end
