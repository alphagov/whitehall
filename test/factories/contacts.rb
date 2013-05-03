FactoryGirl.define do
  factory :contact do
    title "Contact description"
    contact_type { ContactType::General }
  end

  factory :contact_with_country, parent: :contact do
    street_address '29 Acacier Road'
    association :country, factory: :world_location
  end
end
