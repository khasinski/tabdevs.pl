module Admin
  class FlagsController < BaseController
    before_action :set_flag, only: [:resolve, :dismiss]

    def index
      @flags = Flag.pending.includes(:user, :flaggable).order(created_at: :desc)
    end

    def resolve
      @flag.resolve!(current_user)

      if params[:hide_content] == "1" && @flag.flaggable.respond_to?(:status=)
        @flag.flaggable.update!(status: :hidden)
      end

      flash[:notice] = t("admin.flash.flag_resolved")
      redirect_to admin_flags_path
    end

    def dismiss
      @flag.resolve!(current_user)
      flash[:notice] = t("admin.flash.flag_dismissed")
      redirect_to admin_flags_path
    end

    private

    def set_flag
      @flag = Flag.find(params[:id])
    end
  end
end
