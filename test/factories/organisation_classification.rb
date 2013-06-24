FactoryGirl.define do
  factory :organisation_classification do
    organisation { FactoryGirl.build(:organisation) }
    classification { FactoryGirl.build(:topic) }
    lead false
  end
end
