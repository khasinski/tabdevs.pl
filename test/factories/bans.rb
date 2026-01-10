FactoryBot.define do
  factory :ban do
    association :user
    association :moderator, factory: :user
    reason { "Naruszenie regulaminu" }
    ban_type { :soft }
    expires_at { 7.days.from_now }

    trait :hard do
      ban_type { :hard }
    end

    trait :permanent do
      expires_at { nil }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
