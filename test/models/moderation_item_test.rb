require "test_helper"

class ModerationItemTest < ActiveSupport::TestCase
  test "valid moderation item" do
    item = build(:moderation_item)
    assert item.valid?
  end

  test "requires moderatable" do
    item = build(:moderation_item, moderatable: nil)
    assert_not item.valid?
  end

  test "moderator is optional" do
    item = build(:moderation_item, moderator: nil)
    assert item.valid?
  end

  test "approve! sets status and moderator" do
    item = create(:moderation_item, status: :pending)
    moderator = create(:user, :moderator)

    item.approve!(moderator)

    assert item.approved?
    assert_equal moderator, item.moderator
    assert_not_nil item.resolved_at
  end

  test "reject! sets status and moderator" do
    item = create(:moderation_item, status: :pending)
    moderator = create(:user, :moderator)

    item.reject!(moderator)

    assert item.rejected?
    assert_equal moderator, item.moderator
    assert_not_nil item.resolved_at
  end

  test "pending_review scope returns only pending items" do
    pending = create(:moderation_item, status: :pending)
    approved = create(:moderation_item, :approved)
    rejected = create(:moderation_item, :rejected)

    results = ModerationItem.pending_review

    assert_includes results, pending
    assert_not_includes results, approved
    assert_not_includes results, rejected
  end

  test "reason enum works correctly" do
    ai_suggested = build(:moderation_item, reason: :ai_suggested)
    user_report = build(:moderation_item, reason: :user_report)
    duplicate = build(:moderation_item, reason: :duplicate)

    assert ai_suggested.ai_suggested?
    assert user_report.user_report?
    assert duplicate.duplicate?
  end

  test "status enum works correctly" do
    pending = build(:moderation_item, status: :pending)
    approved = build(:moderation_item, status: :approved)
    rejected = build(:moderation_item, status: :rejected)

    assert pending.pending?
    assert approved.approved?
    assert rejected.rejected?
  end

  test "can moderate both posts and comments" do
    post_item = build(:moderation_item, moderatable: create(:post))
    comment_item = build(:moderation_item, moderatable: create(:comment))

    assert post_item.valid?
    assert comment_item.valid?
  end
end
