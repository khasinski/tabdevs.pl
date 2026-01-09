require "test_helper"

class VotingServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @author = create(:user, karma: 100)
    @post = create(:post, author: @author, score: 1)
  end

  test "upvote creates vote and increments score" do
    service = VotingService.new(votable: @post, user: @user)

    assert_difference -> { Vote.count }, 1 do
      assert service.upvote!
    end

    @post.reload
    assert_equal 2, @post.score
  end

  test "upvote increments author karma" do
    service = VotingService.new(votable: @post, user: @user)

    assert_difference -> { @author.reload.karma }, 1 do
      service.upvote!
    end
  end

  test "upvote does not change karma when voting own post" do
    service = VotingService.new(votable: @post, user: @author)

    assert_no_difference -> { @author.reload.karma } do
      service.upvote!
    end
  end

  test "downvote requires sufficient karma" do
    SiteSetting.set(:downvote_threshold, 100)
    low_karma_user = create(:user, karma: 0)
    service = VotingService.new(votable: @post, user: low_karma_user)

    assert_not service.downvote!
    assert_equal :insufficient_karma, service.error
  end

  test "downvote works with sufficient karma" do
    high_karma_user = create(:user, karma: 500)
    service = VotingService.new(votable: @post, user: high_karma_user)

    assert_difference -> { Vote.count }, 1 do
      assert service.downvote!
    end

    @post.reload
    assert_equal 0, @post.score
  end

  test "downvote decrements author karma" do
    high_karma_user = create(:user, karma: 500)
    service = VotingService.new(votable: @post, user: high_karma_user)

    assert_difference -> { @author.reload.karma }, -1 do
      service.downvote!
    end
  end

  test "changing vote updates score correctly" do
    high_karma_user = create(:user, karma: 500)
    service = VotingService.new(votable: @post, user: high_karma_user)

    service.upvote!
    @post.reload
    assert_equal 2, @post.score

    service.downvote!
    @post.reload
    assert_equal 0, @post.score
  end

  test "remove_vote deletes vote and updates score" do
    service = VotingService.new(votable: @post, user: @user)
    service.upvote!

    @post.reload
    assert_equal 2, @post.score

    assert_difference -> { Vote.count }, -1 do
      assert service.remove_vote!
    end

    @post.reload
    assert_equal 1, @post.score
  end

  test "remove_vote returns false when no vote exists" do
    service = VotingService.new(votable: @post, user: @user)
    assert_not service.remove_vote!
  end

  test "remove_vote reverses karma change" do
    service = VotingService.new(votable: @post, user: @user)
    service.upvote!

    assert_difference -> { @author.reload.karma }, -1 do
      service.remove_vote!
    end
  end

  test "voting on comment works" do
    comment = create(:comment, post: @post, author: @author)
    service = VotingService.new(votable: comment, user: @user)

    assert_difference -> { Vote.count }, 1 do
      assert service.upvote!
    end
  end
end
