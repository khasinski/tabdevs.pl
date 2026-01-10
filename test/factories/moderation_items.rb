FactoryBot.define do
  factory :moderation_item do
    association :moderatable, factory: :post
    association :moderator, factory: :user
    reason { :ai_suggested }
    status { :pending }
    resolved_at { nil }

    trait :approved do
      status { :approved }
      resolved_at { Time.current }
    end

    trait :rejected do
      status { :rejected }
      resolved_at { Time.current }
    end

    trait :user_report do
      reason { :user_report }
    end
  end
end
