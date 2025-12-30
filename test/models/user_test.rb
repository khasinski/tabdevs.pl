require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates username presence" do
    user = build(:user, username: nil)
    assert_not user.valid?
    assert_includes user.errors[:username], I18n.t("activerecord.errors.messages.blank")
  end

  test "validates username uniqueness" do
    create(:user, username: "unique")
    user = build(:user, username: "unique")
    assert_not user.valid?
    assert_includes user.errors[:username], I18n.t("activerecord.errors.messages.taken")
  end

  test "validates username format" do
    user = build(:user, username: "invalid@name")
    assert_not user.valid?
  end

  test "validates email presence" do
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], I18n.t("activerecord.errors.messages.blank")
  end

  test "validates email format" do
    user = build(:user, email: "not-an-email")
    assert_not user.valid?
  end

  test "normalizes email" do
    user = create(:user, email: "  TEST@EXAMPLE.COM  ")
    assert_equal "test@example.com", user.email
  end

  test "bot? returns true for tabdevs-bot" do
    user = build(:user, :bot)
    assert user.bot?
  end

  test "bot? returns false for regular users" do
    user = build(:user)
    assert_not user.bot?
  end

  test "can_downvote? checks karma threshold" do
    SiteSetting.set(:downvote_threshold, 10)

    low_karma = build(:user, karma: 5)
    high_karma = build(:user, karma: 15)

    assert_not low_karma.can_downvote?
    assert high_karma.can_downvote?
  end

  test "voted_for? returns true when user has voted" do
    user = create(:user)
    post = create(:post)
    post.upvote!(user)

    assert user.voted_for?(post)
  end

  test "voted_for? returns false when user has not voted" do
    user = create(:user)
    post = create(:post)

    assert_not user.voted_for?(post)
  end

  test "has_password? returns true when password is set" do
    user = create(:user, :with_password)
    assert user.has_password?
  end

  test "has_password? returns false when password is not set" do
    user = create(:user)
    assert_not user.has_password?
  end

  test "generate_username_from_email extracts username from email" do
    username = User.generate_username_from_email("john-doe@example.com")
    assert_equal "john-doe", username
  end

  test "generate_username_from_email handles short usernames" do
    username = User.generate_username_from_email("ab@example.com")
    assert_equal "user", username
  end

  test "generate_username_from_email appends number for duplicates" do
    create(:user, username: "john")
    username = User.generate_username_from_email("john@example.com")
    assert_equal "john1", username
  end

  test "generate_username_from_email removes invalid characters" do
    username = User.generate_username_from_email("john+test@example.com")
    assert_equal "johntest", username
  end
end
