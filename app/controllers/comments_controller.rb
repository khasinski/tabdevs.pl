class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:create]
  before_action :set_comment, only: [:edit, :update, :destroy, :upvote, :downvote, :remove_vote]
  before_action :authorize_edit!, only: [:edit, :update, :destroy]

  def create
    unless current_user.can_comment?
      flash[:alert] = t("flash.comments.limit_reached")
      return redirect_to @post
    end

    @comment = @post.comments.build(comment_params)
    @comment.author = current_user

    if @comment.save
      @comment.upvote!(current_user)  # Auto-upvote own comment
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: t("flash.comments.created") }
      end
    else
      flash[:alert] = @comment.errors.full_messages.join(", ")
      redirect_to @post
    end
  end

  def edit
    @post = @comment.post
  end

  def update
    if @comment.update(comment_params)
      @comment.mark_as_edited!
      redirect_to @comment.post, notice: t("flash.comments.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    post = @comment.post
    @comment.update!(status: :removed)
    redirect_to post, notice: t("flash.comments.deleted")
  end

  def upvote
    @comment.upvote!(current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @comment.post }
    end
  end

  def downvote
    if @comment.downvote!(current_user)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @comment.post }
      end
    else
      flash[:alert] = t("flash.votes.downvote_karma")
      redirect_to @comment.post
    end
  end

  def remove_vote
    @comment.remove_vote!(current_user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @comment.post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def authorize_edit!
    unless @comment.can_be_edited_by?(current_user)
      flash[:alert] = t("flash.comments.edit_not_allowed")
      redirect_to @comment.post
    end
  end
end
