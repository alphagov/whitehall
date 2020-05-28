FactoryBot.define do
  factory :organisation_classification do
    organisation { FactoryBot.build(:organisation) }
    classification { FactoryBot.build(:topical_event) }
    lead { false }
  end
end
