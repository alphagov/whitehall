FactoryGirl.define do
  factory :document_attachment do
    association :edition, factory: :publication
    attachment
  end
end