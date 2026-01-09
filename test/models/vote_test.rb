require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @post = create(:post)
  end

  test "valid upvote" do
    vote = Vote.new(user: @user, votable: @post, value: 1)
    assert vote.valid?
  end

  test "valid downvote" do
    vote = Vote.new(user: @user, votable: @post, value: -1)
    assert vote.valid?
  end

  test "invalid value rejected" do
    vote = Vote.new(user: @user, votable: @post, value: 2)
    assert_not vote.valid?
    assert vote.errors[:value].any?
  end

  test "zero value rejected" do
    vote = Vote.new(user: @user, votable: @post, value: 0)
    assert_not vote.valid?
  end

  test "value is required" do
    vote = Vote.new(user: @user, votable: @post)
    assert_not vote.valid?
    assert_includes vote.errors[:value], "nie może być puste"
  end

  test "user can vote only once per votable" do
    Vote.create!(user: @user, votable: @post, value: 1)
    duplicate = Vote.new(user: @user, votable: @post, value: -1)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "jest już zajęte"
  end

  test "user can vote on different posts" do
    post2 = create(:post)
    Vote.create!(user: @user, votable: @post, value: 1)
    vote2 = Vote.new(user: @user, votable: post2, value: 1)
    assert vote2.valid?
  end

  test "different users can vote on same post" do
    user2 = create(:user)
    Vote.create!(user: @user, votable: @post, value: 1)
    vote2 = Vote.new(user: user2, votable: @post, value: 1)
    assert vote2.valid?
  end

  test "upvotes scope returns only upvotes" do
    Vote.create!(user: @user, votable: @post, value: 1)
    user2 = create(:user)
    Vote.create!(user: user2, votable: @post, value: -1)

    assert_equal 1, Vote.upvotes.count
    assert_equal 1, Vote.upvotes.first.value
  end

  test "downvotes scope returns only downvotes" do
    Vote.create!(user: @user, votable: @post, value: 1)
    user2 = create(:user)
    Vote.create!(user: user2, votable: @post, value: -1)

    assert_equal 1, Vote.downvotes.count
    assert_equal(-1, Vote.downvotes.first.value)
  end

  test "can vote on comments" do
    comment = create(:comment, post: @post)
    vote = Vote.new(user: @user, votable: comment, value: 1)
    assert vote.valid?
  end
end
