FactoryGirl.define do
  factory :document_series do
    name "Monthly Beard Update"
    summary "A monthly update on all things to do with Beards."
    association :organisation

    trait(:with_group) do
      groups { FactoryGirl.build_list :document_series_group, 1 }
    end
  end
end
