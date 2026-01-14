class Event < ApplicationRecord
  enum :event_type, {
    meetup: "meetup",
    conference: "conference",
    workshop: "workshop",
    hackathon: "hackathon",
    other: "other"
  }, prefix: true

  enum :source, {
    crossweb: "crossweb",
    meetup_com: "meetup_com",
    eventbrite: "eventbrite",
    manual: "manual"
  }, prefix: true

  validates :title, presence: true
  validates :url, presence: true
  validates :starts_at, presence: true
  validates :external_id, uniqueness: true, allow_nil: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :past, -> { where("starts_at < ?", Time.current).order(starts_at: :desc) }
  scope :this_week, -> { where(starts_at: Time.current..1.week.from_now).order(:starts_at) }
  scope :this_month, -> { where(starts_at: Time.current..1.month.from_now).order(:starts_at) }
  scope :free_only, -> { where(free: true) }
  scope :in_city, ->(city) { where("location ILIKE ?", "%#{city}%") }

  def online?
    location&.downcase&.include?("online") || location&.downcase&.include?("zdalnie")
  end

  def past?
    starts_at < Time.current
  end

  def upcoming?
    starts_at >= Time.current
  end
end
