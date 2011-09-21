FactoryGirl.define do
  factory :policy do
    title 'policy-title'
    body  'policy-body'
  end

  factory :draft_policy, :parent => :policy do
    submitted false
  end
  
  factory :submitted_policy, :parent => :policy do
    submitted true
  end

  factory :user do
    name 'Daaaaaaave'
  end
end