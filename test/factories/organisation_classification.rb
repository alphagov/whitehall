FactoryGirl.define do
  factory :organisation_classification do
    organisation { FactoryGirl.build(:organisation) }
    topic { FactoryGirl.build(:topic) }
    lead false
  end
end
