FactoryBot.define do
  factory :flag do
    association :user
    association :flaggable, factory: :post
    reason { :spam }
    description { nil }
    resolved_at { nil }
    resolved_by { nil }

    trait :resolved do
      resolved_at { Time.current }
      association :resolved_by, factory: :user
    end

    trait :offensive do
      reason { :offensive }
    end

    trait :other do
      reason { :other }
      description { "Custom reason for flagging this content" }
    end

    trait :on_comment do
      association :flaggable, factory: :comment
    end
  end
end
