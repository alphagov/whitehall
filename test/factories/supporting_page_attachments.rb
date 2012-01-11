FactoryGirl.define do
  factory :supporting_page_attachment do
    association :supporting_page
    attachment
  end
end