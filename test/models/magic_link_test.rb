require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "generates token on create" do
    link = @user.magic_links.create!
    assert link.token.present?
    assert link.token.length >= 32
  end

  test "sets expiry on create" do
    link = @user.magic_links.create!
    assert link.expires_at.present?
    assert link.expires_at > Time.current
  end

  test "token is unique" do
    link1 = @user.magic_links.create!
    link2 = @user.magic_links.create!
    assert_not_equal link1.token, link2.token
  end

  test "expired? returns true when expired" do
    link = @user.magic_links.create!
    link.update_column(:expires_at, 1.hour.ago)
    assert link.expired?
  end

  test "expired? returns false when not expired" do
    link = @user.magic_links.create!
    assert_not link.expired?
  end

  test "used? returns true when used" do
    link = @user.magic_links.create!
    link.update!(used_at: Time.current)
    assert link.used?
  end

  test "used? returns false when not used" do
    link = @user.magic_links.create!
    assert_not link.used?
  end

  test "valid_for_use? returns true when valid" do
    link = @user.magic_links.create!
    assert link.valid_for_use?
  end

  test "valid_for_use? returns false when expired" do
    link = @user.magic_links.create!
    link.update_column(:expires_at, 1.hour.ago)
    assert_not link.valid_for_use?
  end

  test "valid_for_use? returns false when used" do
    link = @user.magic_links.create!
    link.update!(used_at: Time.current)
    assert_not link.valid_for_use?
  end

  test "use! marks link as used" do
    link = @user.magic_links.create!
    assert link.use!
    assert link.used?
  end

  test "use! returns false when already used" do
    link = @user.magic_links.create!
    link.use!
    assert_not link.use!
  end

  test "use! returns false when expired" do
    link = @user.magic_links.create!
    link.update_column(:expires_at, 1.hour.ago)
    assert_not link.use!
  end

  test "find_and_use returns link when valid" do
    link = @user.magic_links.create!
    found = MagicLink.find_and_use(link.token)
    assert_equal link, found
    assert found.used?
  end

  test "find_and_use returns nil for invalid token" do
    assert_nil MagicLink.find_and_use("invalid_token")
  end

  test "find_and_use returns nil for expired link" do
    link = @user.magic_links.create!
    link.update_column(:expires_at, 1.hour.ago)
    assert_nil MagicLink.find_and_use(link.token)
  end

  test "find_and_use returns nil for already used link" do
    link = @user.magic_links.create!
    link.update!(used_at: Time.current)
    assert_nil MagicLink.find_and_use(link.token)
  end

  test "valid scope returns only valid links" do
    valid_link = @user.magic_links.create!
    expired_link = @user.magic_links.create!
    expired_link.update_column(:expires_at, 1.hour.ago)
    used_link = @user.magic_links.create!
    used_link.update!(used_at: Time.current)

    valid_links = MagicLink.valid
    assert_includes valid_links, valid_link
    assert_not_includes valid_links, expired_link
    assert_not_includes valid_links, used_link
  end
end
