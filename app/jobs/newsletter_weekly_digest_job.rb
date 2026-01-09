class NewsletterWeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    posts = Post.visible
                .where("created_at > ?", 1.week.ago)
                .order(score: :desc)
                .limit(10)

    return if posts.empty?

    NewsletterSubscription.active.find_each do |subscription|
      NewsletterMailer.weekly_digest(subscription, posts).deliver_later
    end
  end
end
