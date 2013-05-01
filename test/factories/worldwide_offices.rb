FactoryGirl.define do
  factory :worldwide_office do
    ignore do
      title { 'Contact title' }
    end
    contact { create :contact_with_country, title: title }
    worldwide_organisation
    worldwide_office_type_id { WorldwideOfficeType.all.sample.id }
  end
end
