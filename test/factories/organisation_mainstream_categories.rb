FactoryGirl.define do
  factory :organisation_mainstream_category do
    organisation { Organisation.first || FactoryGirl.create(:organisation) }
    mainstream_category { MainstreamCategory.first || FactoryGirl.create(:mainstream_category) }
    sequence(:ordering) { |n| n }
  end
end
