FactoryBot.define do
  factory :navigation_item do
    navigation_edition
    child_document { FactoryBot.create(:document) }
  end
end
