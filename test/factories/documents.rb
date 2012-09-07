FactoryGirl.define do
  factory :document do
    sequence(:slug) { |index| "slug-#{index}" }
  end
end
