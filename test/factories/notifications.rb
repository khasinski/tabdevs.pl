FactoryBot.define do
  factory :notification do
    association :user
    association :notifiable, factory: :comment
    association :actor, factory: :user
    notification_type { :comment_reply }
    read_at { nil }

    trait :read do
      read_at { Time.current }
    end

    trait :post_comment do
      notification_type { :post_comment }
    end

    trait :mention do
      notification_type { :mention }
    end
  end
end
