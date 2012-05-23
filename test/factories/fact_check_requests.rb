FactoryGirl.define do
  factory :fact_check_request do
    association :edition, factory: :policy
    association :requestor, factory: :fact_check_requestor
    email_address "fact-checker@example.com"
  end
end