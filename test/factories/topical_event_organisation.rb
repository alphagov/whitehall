FactoryBot.define do
  factory :topical_event_organisation do
    organisation { FactoryBot.build(:organisation) }
    topical_event { FactoryBot.build(:topical_event) }
    lead { false }
  end
end
