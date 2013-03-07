FactoryGirl.define do
  factory :worldwide_office do
    contact
    worldwide_organisation
    worldwide_office_type_id { WorldwideOfficeType.all.sample.id }
  end
end
