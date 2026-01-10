class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.includes(:notifiable, :actor)
    @pagy, @notifications = pagy(:offset, @notifications, limit: 20)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    Notification.mark_all_as_read!(current_user)
    redirect_to notifications_path, notice: t("flash.notifications.marked_all_read")
  end
end
