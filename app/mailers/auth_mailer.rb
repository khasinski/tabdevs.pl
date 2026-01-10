class AuthMailer < ApplicationMailer
  def magic_link(user, magic_link)
    @user = user
    @magic_link = magic_link
    @login_url = auth_callback_url(token: magic_link.token)

    Resend::Emails.send({
      from: "#{app_name} <noreply@#{app_host}>",
      to: user.email,
      subject: "Twój link do logowania - #{app_name}",
      html: render_to_string(template: "auth_mailer/magic_link", layout: "mailer")
    })
  end
end
