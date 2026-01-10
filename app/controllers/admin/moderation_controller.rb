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
      toggle_status(Post, :hidden, "admin.flash.post_hidden")
    end

    def unhide_post
      toggle_status(Post, :active, "admin.flash.post_restored")
    end

    def hide_comment
      toggle_status(Comment, :hidden, "admin.flash.comment_hidden")
    end

    def unhide_comment
      toggle_status(Comment, :active, "admin.flash.comment_restored")
    end

    private

    def toggle_status(model, status, flash_key)
      record = model.find(params[:id])
      record.update!(status: status)
      flash[:notice] = t(flash_key)
      redirect_back fallback_location: admin_dashboard_path
    end
  end
end
