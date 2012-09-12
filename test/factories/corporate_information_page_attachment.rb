FactoryGirl.define do
  factory :corporate_information_page_attachment do
    association :corporate_information_page
    attachment
  end
end