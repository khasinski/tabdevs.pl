FactoryBot.define do
  factory :post do
    association :author, factory: :user
    sequence(:title) { |n| "Test Post #{n}" }
    post_type { :link }
    url { "https://example.com/article" }
    score { 1 }
    status { :active }

    trait :text do
      post_type { :text }
      url { nil }
      body { "This is a text post with some content." }
    end

    trait :with_tag do
      tag { :ask }
    end

    trait :hidden do
      status { :hidden }
    end

    trait :removed do
      status { :removed }
    end

    trait :old do
      created_at { 2.days.ago }
    end
  end
end
