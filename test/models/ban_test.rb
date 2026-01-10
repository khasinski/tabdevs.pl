require "test_helper"

class BanTest < ActiveSupport::TestCase
  test "valid ban" do
    ban = build(:ban)
    assert ban.valid?
  end

  test "requires user" do
    ban = build(:ban, user: nil)
    assert_not ban.valid?
  end

  test "requires moderator" do
    ban = build(:ban, moderator: nil)
    assert_not ban.valid?
  end

  test "requires reason" do
    ban = build(:ban, reason: nil)
    assert_not ban.valid?
  end

  test "active? returns true for future expiry" do
    ban = build(:ban, expires_at: 1.day.from_now)
    assert ban.active?
  end

  test "active? returns true for permanent ban" do
    ban = build(:ban, :permanent)
    assert ban.active?
  end

  test "active? returns false for expired ban" do
    ban = build(:ban, :expired)
    assert_not ban.active?
  end

  test "permanent? returns true when expires_at is nil" do
    ban = build(:ban, :permanent)
    assert ban.permanent?
  end

  test "permanent? returns false when expires_at is set" do
    ban = build(:ban, expires_at: 1.day.from_now)
    assert_not ban.permanent?
  end

  test "expired? returns true for past expiry" do
    ban = build(:ban, :expired)
    assert ban.expired?
  end

  test "expired? returns false for future expiry" do
    ban = build(:ban, expires_at: 1.day.from_now)
    assert_not ban.expired?
  end

  test "expired? returns false for permanent ban" do
    ban = build(:ban, :permanent)
    assert_not ban.expired?
  end

  test "remaining_time returns nil for permanent ban" do
    ban = build(:ban, :permanent)
    assert_nil ban.remaining_time
  end

  test "remaining_time returns nil for expired ban" do
    ban = build(:ban, :expired)
    assert_nil ban.remaining_time
  end

  test "remaining_time returns positive value for active ban" do
    ban = build(:ban, expires_at: 2.days.from_now)
    remaining = ban.remaining_time

    assert remaining > 0
    assert remaining <= 2.days
  end

  test "active scope returns only active bans" do
    user = create(:user)
    moderator = create(:user, :moderator)
    active = create(:ban, user: user, moderator: moderator, expires_at: 1.day.from_now)
    expired = create(:ban, user: user, moderator: moderator, expires_at: 1.day.ago)
    permanent = create(:ban, user: user, moderator: moderator, expires_at: nil)

    results = Ban.active

    assert_includes results, active
    assert_includes results, permanent
    assert_not_includes results, expired
  end

  test "expired scope returns only expired bans" do
    user = create(:user)
    moderator = create(:user, :moderator)
    active = create(:ban, user: user, moderator: moderator, expires_at: 1.day.from_now)
    expired = create(:ban, user: user, moderator: moderator, expires_at: 1.day.ago)
    permanent = create(:ban, user: user, moderator: moderator, expires_at: nil)

    results = Ban.expired

    assert_not_includes results, active
    assert_not_includes results, permanent
    assert_includes results, expired
  end

  test "ban_type enum works correctly" do
    soft = build(:ban, ban_type: :soft)
    hard = build(:ban, ban_type: :hard)

    assert soft.soft?
    assert hard.hard?
  end
end
