FactoryBot.define do
  factory :organisation_classification do
    organisation { FactoryBot.build(:organisation) }
    classification { FactoryBot.build(:topic) }
    lead { false }
  end
end
