require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @post = create(:post)
  end

  test "requires login for index" do
    get bookmarks_path
    assert_redirected_to login_path
  end

  test "shows bookmarks index for logged in user" do
    bookmark = create(:bookmark, user: @user, post: @post)
    login_user(@user)

    get bookmarks_path
    assert_response :success
    assert_includes response.body, @post.title
  end

  test "requires login to create bookmark" do
    post post_bookmark_path(@post)
    assert_redirected_to login_path
  end

  test "creates bookmark" do
    login_user(@user)

    assert_difference "Bookmark.count", 1 do
      post post_bookmark_path(@post)
    end

    assert @user.bookmarks.exists?(post: @post)
  end

  test "does not duplicate bookmark" do
    create(:bookmark, user: @user, post: @post)
    login_user(@user)

    assert_no_difference "Bookmark.count" do
      post post_bookmark_path(@post)
    end
  end

  test "creates bookmark via turbo stream" do
    login_user(@user)

    post post_bookmark_path(@post), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.media_type, "turbo-stream"
  end

  test "requires login to destroy bookmark" do
    delete post_bookmark_path(@post)
    assert_redirected_to login_path
  end

  test "destroys bookmark" do
    create(:bookmark, user: @user, post: @post)
    login_user(@user)

    assert_difference "Bookmark.count", -1 do
      delete post_bookmark_path(@post)
    end

    assert_not @user.bookmarks.exists?(post: @post)
  end

  test "handles destroy when bookmark does not exist" do
    login_user(@user)

    assert_no_difference "Bookmark.count" do
      delete post_bookmark_path(@post)
    end

    assert_response :redirect
  end

  test "destroys bookmark via turbo stream" do
    create(:bookmark, user: @user, post: @post)
    login_user(@user)

    delete post_bookmark_path(@post), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.media_type, "turbo-stream"
  end
end
