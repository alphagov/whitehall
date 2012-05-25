FactoryGirl.define do
  factory :edition_attachment do
    association :edition, factory: :publication
    attachment
  end
end