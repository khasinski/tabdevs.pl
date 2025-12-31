class PingSearchEnginesJob < ApplicationJob
  queue_as :default

  WEBSUB_HUBS = [
    "https://pubsubhubbub.appspot.com/",
    "https://pubsubhubbub.superfeedr.com/"
  ].freeze

  INDEXNOW_ENDPOINTS = [
    "https://api.indexnow.org/indexnow",
    "https://www.bing.com/indexnow"
  ].freeze

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post&.active?

    ping_websub_hubs
    ping_indexnow(post)
  end

  private

  def ping_websub_hubs
    feed_url = "https://tabdevs.pl/feed.rss"

    WEBSUB_HUBS.each do |hub|
      uri = URI.parse(hub)
      begin
        response = Net::HTTP.post_form(uri, {
          "hub.mode" => "publish",
          "hub.url" => feed_url
        })
        Rails.logger.info "[WebSub] Pinged #{hub}: #{response.code}"
      rescue => e
        Rails.logger.warn "[WebSub] Failed to ping #{hub}: #{e.message}"
      end
    end
  end

  def ping_indexnow(post)
    host = "tabdevs.pl"
    key = indexnow_key
    post_url = "https://#{host}/posts/#{post.id}"

    INDEXNOW_ENDPOINTS.each do |endpoint|
      begin
        uri = URI.parse("#{endpoint}?url=#{CGI.escape(post_url)}&key=#{key}")
        response = Net::HTTP.get_response(uri)
        Rails.logger.info "[IndexNow] Pinged #{endpoint}: #{response.code}"
      rescue => e
        Rails.logger.warn "[IndexNow] Failed to ping #{endpoint}: #{e.message}"
      end
    end
  end

  def indexnow_key
    @indexnow_key ||= Rails.application.credentials.dig(:indexnow_key) || default_key
  end

  def default_key
    Digest::SHA256.hexdigest("tabdevs.pl-indexnow")[0..31]
  end
end
