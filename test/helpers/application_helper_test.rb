require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "display_username returns translation for nil user" do
    assert_equal I18n.t("views.common.deleted_user"), display_username(nil)
  end

  test "display_username returns translation for deleted user" do
    user = User.new(username: "deleted")
    assert_equal I18n.t("views.common.deleted_user"), display_username(user)
  end

  test "display_username returns username for regular user" do
    user = User.new(username: "john")
    assert_equal "john", display_username(user)
  end

  test "deleted_user? returns true for nil" do
    assert deleted_user?(nil)
  end

  test "deleted_user? returns true for user with deleted username" do
    user = User.new(username: "deleted")
    assert deleted_user?(user)
  end

  test "deleted_user? returns false for regular user" do
    user = User.new(username: "john")
    assert_not deleted_user?(user)
  end
end
