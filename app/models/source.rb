class Source < ApplicationRecord
  enum :source_type, { rss: 0, github: 1, blog: 2 }

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  scope :enabled, -> { where(enabled: true) }
  scope :due_for_fetch, -> { enabled.where("last_fetched_at IS NULL OR last_fetched_at < ?", 1.hour.ago) }

  def mark_fetched!
    update!(last_fetched_at: Time.current)
  end
end
