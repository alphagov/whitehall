FactoryGirl.define do
  factory :contact do
    title "Contact description"
  end

  factory :contact_with_country, parent: :contact do
    street_address '29 Acacier Road'
    country
  end
end
