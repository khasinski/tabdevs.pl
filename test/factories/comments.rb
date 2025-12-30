FactoryBot.define do
  factory :comment do
    association :author, factory: :user
    association :post
    body { "This is a test comment." }
    score { 1 }
    status { :active }

    trait :with_parent do
      association :parent, factory: :comment
    end

    trait :removed do
      status { :removed }
    end
  end
end
