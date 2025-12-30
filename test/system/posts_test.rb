require "test_helper"

class PostsTest < ActionDispatch::IntegrationTest
  test "viewing a link post" do
    post = create(:post, title: "Test Link Post", url: "https://example.com")

    visit post_path(post)

    assert_text "Test Link Post"
    assert_selector "a[href='https://example.com']"
  end

  test "viewing a text post shows body" do
    post = create(:post, :text, title: "Test Text Post", body: "This is the body content")

    visit post_path(post)

    assert_text "Test Text Post"
    assert_text "This is the body content"
  end

  test "guest cannot create post" do
    visit new_post_path

    assert_current_path login_path
  end

  test "logged in user can create link post" do
    user = create(:user)
    login_as(user)

    visit new_post_path

    fill_in "Tytuł", with: "My New Post"
    fill_in "URL", with: "https://example.com/new"
    click_button "Dodaj post"

    assert_text "Post został dodany"
    assert_text "My New Post"
  end

  test "logged in user can create text post" do
    user = create(:user)
    login_as(user)

    visit new_post_path

    fill_in "Tytuł", with: "My Text Post"
    fill_in "Treść (opcjonalne)", with: "This is my text content"
    click_button "Dodaj post"

    assert_text "Post został dodany"
    assert_text "This is my text content"
  end

  test "author can edit post within grace period" do
    SiteSetting.set(:edit_grace_period_minutes, 15)
    user = create(:user)
    post = create(:post, author: user, title: "Original Title", created_at: 5.minutes.ago)
    login_as(user)

    visit post_path(post)
    click_link "edytuj"

    fill_in "Tytuł", with: "Updated Title"
    click_button "Zapisz zmiany"

    assert_text "Post został zaktualizowany"
    assert_text "Updated Title"
  end
end
