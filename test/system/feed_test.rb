require "test_helper"

class FeedTest < ActionDispatch::IntegrationTest
  test "visiting the homepage shows posts" do
    post = create(:post, title: "Test Post Title")

    visit root_path

    assert_text "Test Post Title"
    assert_text "tabdevs.pl"
  end

  test "posts are sorted by top ranking by default" do
    old_popular = create(:post, title: "Old Popular", score: 100, created_at: 2.days.ago)
    new_medium = create(:post, title: "New Medium", score: 10, created_at: 1.hour.ago)

    visit root_path

    # New posts should appear first due to ranking algorithm
    assert page.body.index("New Medium") < page.body.index("Old Popular")
  end

  test "new feed shows posts chronologically" do
    older = create(:post, title: "Older Post", created_at: 2.hours.ago)
    newer = create(:post, title: "Newer Post", created_at: 1.hour.ago)

    visit new_posts_path

    assert page.body.index("Newer Post") < page.body.index("Older Post")
  end

  test "clicking post title navigates to external url for link posts" do
    post = create(:post, title: "Click Me Post", url: "https://example.com/article")

    visit root_path
    # Link posts go to external URL, so we just verify the link exists with correct href
    assert_selector "a[href='https://example.com/article']", text: "Click Me Post"
  end

  test "clicking text post title navigates to post page" do
    post = create(:post, :text, title: "Click Me Text Post")

    visit root_path
    click_link "Click Me Text Post"

    assert_current_path post_path(post)
  end

  test "guest sees login link" do
    visit root_path

    assert_text "zaloguj"
  end

  test "logged in user sees their username" do
    user = create(:user, username: "testuser")
    login_as(user)

    visit root_path

    assert_text "testuser"
    assert_text "wyloguj"
  end
end
