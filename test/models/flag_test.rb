require "test_helper"

class FlagTest < ActiveSupport::TestCase
  test "valid flag" do
    flag = build(:flag)
    assert flag.valid?
  end

  test "requires user" do
    flag = build(:flag, user: nil)
    assert_not flag.valid?
  end

  test "requires flaggable" do
    flag = build(:flag, flaggable: nil)
    assert_not flag.valid?
  end

  test "requires reason" do
    flag = build(:flag, reason: nil)
    assert_not flag.valid?
  end

  test "requires description when reason is other" do
    flag = build(:flag, reason: :other, description: nil)
    assert_not flag.valid?
    assert flag.errors[:description].present?
  end

  test "does not require description for non-other reasons" do
    flag = build(:flag, reason: :spam, description: nil)
    assert flag.valid?
  end

  test "validates uniqueness of user per flaggable" do
    user = create(:user)
    post = create(:post)
    create(:flag, user: user, flaggable: post)

    duplicate = build(:flag, user: user, flaggable: post)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].present?
  end

  test "same user can flag different posts" do
    user = create(:user)
    post1 = create(:post)
    post2 = create(:post)

    create(:flag, user: user, flaggable: post1)
    flag2 = build(:flag, user: user, flaggable: post2)

    assert flag2.valid?
  end

  test "resolved? returns false for pending flag" do
    flag = build(:flag, resolved_at: nil)
    assert_not flag.resolved?
  end

  test "resolved? returns true for resolved flag" do
    flag = build(:flag, :resolved)
    assert flag.resolved?
  end

  test "resolve! sets resolved_at and resolved_by" do
    flag = create(:flag)
    moderator = create(:user, :moderator)

    flag.resolve!(moderator)

    assert flag.resolved?
    assert_equal moderator, flag.resolved_by
  end

  test "pending scope returns only pending flags" do
    pending = create(:flag)
    resolved = create(:flag, :resolved)

    results = Flag.pending

    assert_includes results, pending
    assert_not_includes results, resolved
  end

  test "resolved scope returns only resolved flags" do
    pending = create(:flag)
    resolved = create(:flag, :resolved)

    results = Flag.resolved

    assert_not_includes results, pending
    assert_includes results, resolved
  end

  test "recent scope orders by created_at desc" do
    old = create(:flag, created_at: 2.days.ago)
    new = create(:flag, created_at: 1.hour.ago)

    results = Flag.recent

    assert_equal new, results.first
    assert_equal old, results.last
  end

  test "reason enum includes all expected values" do
    assert Flag.reasons.key?("spam")
    assert Flag.reasons.key?("offensive")
    assert Flag.reasons.key?("off_topic")
    assert Flag.reasons.key?("duplicate")
    assert Flag.reasons.key?("misinformation")
    assert Flag.reasons.key?("other")
  end

  test "can flag both posts and comments" do
    post_flag = build(:flag, flaggable: create(:post))
    comment_flag = build(:flag, flaggable: create(:comment))

    assert post_flag.valid?
    assert comment_flag.valid?
  end
end
