# frozen_string_literal: true

class Rack::Attack
  ### Configure Cache ###
  # Use Rails cache for rate limiting
  Rack::Attack.cache.store = Rails.cache

  ### Throttle Spammy Clients ###
  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  ### Login/Magic Link Throttling ###
  # Limit magic link requests to 5 per hour per email
  throttle("magic_links/email", limit: 5, period: 1.hour) do |req|
    if req.path == "/login" && req.post?
      # Normalize email to prevent bypassing
      req.params["email"].to_s.downcase.strip
    end
  end

  # Limit magic link requests to 10 per hour per IP
  throttle("magic_links/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.path == "/login" && req.post?
  end

  ### Post Creation Throttling ###
  # Limit post creation to 10 per hour per IP
  throttle("posts/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.path == "/posts" && req.post?
  end

  ### Comment Creation Throttling ###
  # Limit comment creation to 30 per hour per IP
  throttle("comments/ip", limit: 30, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{/posts/\d+/comments}) && req.post?
  end

  ### Voting Throttling ###
  # Limit voting to 60 per minute per IP (to prevent vote manipulation)
  throttle("votes/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.match?(%r{/(upvote|downvote)$}) && req.post?
  end

  ### Blocklists ###
  # Block requests from bad IPs (can be populated from admin panel or config)
  blocklist("block bad IPs") do |req|
    # You can add IPs to block here or load from database/config
    # Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
    #   req.path.include?("/etc/passwd") || req.path.include?("wp-admin")
    # end
    false
  end

  ### Safelists ###
  # Allow all requests from localhost in development
  safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
  end

  ### Custom Responses ###
  # Return a custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    retry_after = match_data[:period] - (now % match_data[:period])

    [
      429,
      {
        "Content-Type" => "text/html",
        "Retry-After" => retry_after.to_s
      },
      [ "<html><body><h1>429 Too Many Requests</h1><p>Zbyt wiele żądań. Spróbuj ponownie za #{retry_after} sekund.</p></body></html>" ]
    ]
  end

  # Log throttled requests (optional, useful for monitoring)
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled #{req.env['rack.attack.match_type']}: #{req.ip} #{req.request_method} #{req.path}"
  end
end
