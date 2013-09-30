FactoryGirl.define do
  factory :document_collection, class: DocumentCollection, parent: :edition do
    trait(:with_group) do
      groups { FactoryGirl.build_list :document_collection_group, 1 }
    end
  end

  factory :published_document_collection, parent: :document_collection, traits: [:published]
end
