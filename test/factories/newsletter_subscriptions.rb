FactoryBot.define do
  factory :newsletter_subscription do
    sequence(:email) { |n| "subscriber#{n}@example.com" }
    token { SecureRandom.urlsafe_base64(32) }
    confirmed_at { nil }
    unsubscribed_at { nil }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :unsubscribed do
      confirmed_at { 1.week.ago }
      unsubscribed_at { Time.current }
    end
  end
end
