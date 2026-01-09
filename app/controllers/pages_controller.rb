class PagesController < ApplicationController
  def faq
  end

  def terms
  end

  def privacy
  end

  def contact
  end

  def consent
    consent_type = params[:consent]
    expires = 1.year.from_now

    cookies[:cookie_consent_given] = { value: "true", expires: expires }

    if consent_type == "all"
      cookies[:analytics_consent] = { value: "true", expires: expires }
    else
      cookies[:analytics_consent] = { value: "false", expires: expires }
    end

    redirect_back fallback_location: root_path
  end
end
