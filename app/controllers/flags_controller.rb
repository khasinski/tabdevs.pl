class FlagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flaggable

  def new
    if current_user.flagged?(@flaggable)
      redirect_back fallback_location: root_path, alert: t("flash.flags.already_flagged")
      return
    end

    @flag = Flag.new
  end

  def create
    @flag = current_user.flags.build(flag_params)
    @flag.flaggable = @flaggable

    if @flag.save
      redirect_to polymorphic_path(@flaggable.is_a?(Comment) ? @flaggable.post : @flaggable),
                  notice: t("flash.flags.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_flaggable
    if params[:post_id]
      @flaggable = Post.find(params[:post_id])
    elsif params[:comment_id]
      @flaggable = Comment.find(params[:comment_id])
    end
  end

  def flag_params
    params.require(:flag).permit(:reason, :description)
  end
end
