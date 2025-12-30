class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :unread_notifications_count

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    unless logged_in?
      flash[:alert] = t("flash.auth.login_required")
      redirect_to login_path
    end
  end

  def require_admin!
    unless current_user&.admin?
      flash[:alert] = t("flash.auth.no_permission")
      redirect_to root_path
    end
  end

  def require_moderator!
    unless current_user&.admin? || current_user&.moderator?
      flash[:alert] = t("flash.auth.no_permission")
      redirect_to root_path
    end
  end

  def unread_notifications_count
    return 0 unless logged_in?
    @unread_notifications_count ||= current_user.notifications.unread.count
  end
end
