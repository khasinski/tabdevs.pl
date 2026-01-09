require "test_helper"

class SeoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post, author: @user)
  end

  test "sitemap returns xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "sitemap includes posts" do
    get "/sitemap.xml"
    assert_includes response.body, post_path(@post)
  end

  test "sitemap includes users" do
    get "/sitemap.xml"
    assert_includes response.body, @user.username
  end

  test "sitemap excludes hidden posts" do
    hidden_post = create(:post, author: @user, status: :hidden)
    get "/sitemap.xml"
    assert_not_includes response.body, post_path(hidden_post)
  end

  test "feed returns rss" do
    get "/feed.rss"
    assert_response :success
    assert_equal "application/rss+xml; charset=utf-8", response.content_type
  end

  test "feed includes posts" do
    get "/feed.rss"
    assert_includes response.body, @post.title
    assert_includes response.body, "/posts/#{@post.id}"
  end

  test "feed excludes hidden posts" do
    hidden_post = create(:post, author: @user, status: :hidden, title: "Hidden Post Title")
    get "/feed.rss"
    assert_not_includes response.body, hidden_post.title
  end
end
