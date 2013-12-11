FactoryGirl.define do
  factory :document_collection_group_membership do
    document { build :document }
    document_collection_group { build :document_collection_group }
  end
end
