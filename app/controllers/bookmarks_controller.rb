class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :create, :destroy ]

  def index
    @bookmarks = current_user.bookmarks.includes(:post).order(created_at: :desc)
  end

  def create
    bookmark = current_user.bookmarks.find_or_create_by(post: @post)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "bookmark_#{@post.id}",
          partial: "posts/bookmark_button",
          locals: { post: @post, bookmarked: true }
        )
      end
      format.html { redirect_to @post, notice: t("flash.bookmarks.created") }
    end
  end

  def destroy
    bookmark = current_user.bookmarks.find_by(post: @post)
    bookmark&.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "bookmark_#{@post.id}",
          partial: "posts/bookmark_button",
          locals: { post: @post, bookmarked: false }
        )
      end
      format.html { redirect_to @post, notice: t("flash.bookmarks.destroyed") }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
