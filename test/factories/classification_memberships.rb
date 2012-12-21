FactoryGirl.define do
  factory :classification_membership do
    policy
    classification factory: :topic
  end
end