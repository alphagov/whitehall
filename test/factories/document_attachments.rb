FactoryGirl.define do
  factory :document_attachment do
    association :document, factory: :publication
    attachment
  end
end