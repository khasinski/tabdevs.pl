class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :upvote, :downvote, :remove_vote ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :upvote, :downvote, :remove_vote ]
  before_action :authorize_edit!, only: [ :edit, :update, :destroy ]

  def index
    @sort = params[:sort] || "top"

    posts = Post.visible.includes(:author)

    @posts = case @sort
    when "new"
               posts.by_new
    else
               posts.by_top
    end

    @pagy, @posts = pagy(:offset, @posts, limit: 20)
  end

  def search
    @query = params[:q].to_s.strip

    if @query.present?
      @posts = Post.visible
                   .includes(:author)
                   .where("title ILIKE :q OR body ILIKE :q", q: "%#{@query}%")
                   .order(created_at: :desc)
      @pagy, @posts = pagy(:offset, @posts, limit: 20)
    else
      @posts = Post.none
      @pagy = nil
    end
  end

  def show
    @comments = @post.comments.visible.top_level.includes(:author, replies: [ :author, replies: [ :author ] ])
  end

  def new
    unless current_user.can_post?
      flash[:alert] = t("flash.posts.limit_reached")
      return redirect_to root_path
    end
    @post = Post.new
  end

  def create
    unless current_user.can_post?
      flash[:alert] = t("flash.posts.limit_reached")
      return redirect_to root_path
    end

    @post = current_user.posts.build(post_params)

    # Check for duplicate URL
    if @post.url.present?
      duplicate = Post.find_duplicate(@post.url)
      if duplicate
        begin
          duplicate.upvote!(current_user)
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn("Failed to upvote duplicate post #{duplicate.id}: #{e.message}")
        end
        flash[:notice] = t("flash.posts.duplicate")
        return redirect_to duplicate
      end
    end

    if @post.save
      @post.upvote!(current_user)  # Auto-upvote own post
      redirect_to @post, notice: t("flash.posts.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      @post.mark_as_edited!
      redirect_to @post, notice: t("flash.posts.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.update!(status: :removed)
    redirect_to root_path, notice: t("flash.posts.deleted")
  end

  def upvote
    @post.upvote!(current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  def downvote
    if @post.downvote!(current_user)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post }
      end
    else
      flash[:alert] = t("flash.votes.downvote_karma")
      redirect_to @post
    end
  end

  def remove_vote
    @post.remove_vote!(current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :url, :body, :post_type, :tag)
  end

  def authorize_edit!
    unless @post.can_be_edited_by?(current_user)
      flash[:alert] = t("flash.posts.edit_not_allowed")
      redirect_to @post
    end
  end
end
