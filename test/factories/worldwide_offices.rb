FactoryGirl.define do
  factory :worldwide_office do
    association :contact, factory: :contact_with_country
    worldwide_organisation
    worldwide_office_type_id { WorldwideOfficeType.all.sample.id }
  end
end
