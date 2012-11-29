FactoryGirl.define do
  factory :group do
    sequence(:name) { |index| "group-#{index}" }
    organisation
  end
end
