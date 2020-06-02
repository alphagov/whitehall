FactoryBot.define do
  factory :classification_membership do
    publication
    classification factory: :topical_event
  end
end
