FactoryBot.define do
  factory :classification_membership do
    publication
    classification factory: :topic
  end
end
