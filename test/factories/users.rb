FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    karma { 10 }
    role { :user }
    status { :active }

    trait :admin do
      role { :admin }
      karma { 100 }
    end

    trait :moderator do
      role { :moderator }
      karma { 50 }
    end

    trait :bot do
      username { "tabdevs-bot" }
      email { "bot@tabdevs.pl" }
    end

    trait :new_user do
      created_at { 1.hour.ago }
      karma { 0 }
    end

    trait :banned do
      status { :banned }
    end
  end
end
