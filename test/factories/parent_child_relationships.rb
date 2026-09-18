FactoryBot.define do
  factory :parent_child_relationship do
    association :parent_edition, factory: :edition
    association :child_document, factory: :document
  end
end
