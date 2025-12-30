class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create, :password, :password_auth]

  def new
  end

  def create
    email = params[:email].to_s.downcase.strip

    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:error] = t("flash.auth.invalid_email")
      return render :new, status: :unprocessable_entity
    end

    # Rate limiting check
    if rate_limited?(email)
      flash.now[:error] = t("flash.auth.rate_limited")
      return render :new, status: :too_many_requests
    end

    user = User.find_or_create_by!(email: email) do |u|
      u.username = User.generate_username_from_email(email)
    end

    magic_link = user.magic_links.create!
    AuthMailer.magic_link(user, magic_link)

    redirect_to auth_sent_path, notice: t("flash.auth.magic_link_sent", email: email)
  end

  def callback
    magic_link = MagicLink.find_and_use(params[:token])

    if magic_link
      login_user(magic_link.user)
    else
      redirect_to login_path, alert: t("flash.auth.invalid_token")
    end
  end

  def sent
  end

  def password
  end

  def password_auth
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user&.has_password? && user.authenticate(params[:password].to_s)
      login_user(user)
    else
      flash.now[:error] = t("flash.auth.invalid_credentials")
      render :password, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: t("flash.auth.logout_success")
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if current_user
  end

  def login_user(user)
    session[:user_id] = user.id
    redirect_to root_path, notice: t("flash.auth.login_success")
  end

  def rate_limited?(email)
    MagicLink.joins(:user)
             .where(users: { email: email })
             .where("magic_links.created_at > ?", 1.hour.ago)
             .count >= 5
  end
end
