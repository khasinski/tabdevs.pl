class CleanupExpiredMagicLinksJob < ApplicationJob
  queue_as :default

  def perform
    # Delete magic links that expired more than 24 hours ago
    deleted_count = MagicLink.where("expires_at < ?", 24.hours.ago).delete_all
    Rails.logger.info "[GDPR] Cleaned up #{deleted_count} expired magic links"
  end
end
