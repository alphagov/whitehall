FactoryGirl.define do
  factory :document_series do
    name "Monthly Beard Update"
    summary "A monthly update on all things to do with Beards."
    association :organisation
  end
end
