class ApplicationMailer < ActionMailer::Base
  default from: -> { "#{app_name} <noreply@#{app_host}>" }
  layout "mailer"

  private

  def app_host
    ENV.fetch("APP_HOST", "tabdevs.pl")
  end

  def app_name
    ENV.fetch("APP_NAME", "tabdevs.pl")
  end
end
