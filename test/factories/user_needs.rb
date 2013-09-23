FactoryGirl.define do
  factory :user_need do
    user "Example User"
    need "Example Need"
    goal "Example Goal"
    association :organisation
  end
end
