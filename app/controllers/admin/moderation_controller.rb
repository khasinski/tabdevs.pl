module Admin
  class ModerationController < BaseController
    def index
      @items = ModerationItem.pending_review.includes(:moderatable).order(created_at: :desc)
    end

    def approve
      @item = ModerationItem.find(params[:id])
      @item.approve!(current_user)
      flash[:notice] = t("admin.flash.moderation_approved")
      redirect_to admin_moderation_index_path
    end

    def reject
      @item = ModerationItem.find(params[:id])
      @item.reject!(current_user)

      if params[:hide_content] == "1" && @item.moderatable.respond_to?(:status=)
        @item.moderatable.update!(status: :hidden)
      end

      flash[:notice] = t("admin.flash.moderation_rejected")
      redirect_to admin_moderation_index_path
    end

    def hide_post
      @post = Post.find(params[:id])
      @post.update!(status: :hidden)
      flash[:notice] = t("admin.flash.post_hidden")
      redirect_back fallback_location: admin_dashboard_path
    end

    def unhide_post
      @post = Post.find(params[:id])
      @post.update!(status: :active)
      flash[:notice] = t("admin.flash.post_restored")
      redirect_back fallback_location: admin_dashboard_path
    end

    def hide_comment
      @comment = Comment.find(params[:id])
      @comment.update!(status: :hidden)
      flash[:notice] = t("admin.flash.comment_hidden")
      redirect_back fallback_location: admin_dashboard_path
    end

    def unhide_comment
      @comment = Comment.find(params[:id])
      @comment.update!(status: :active)
      flash[:notice] = t("admin.flash.comment_restored")
      redirect_back fallback_location: admin_dashboard_path
    end
  end
end
