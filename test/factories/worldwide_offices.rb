FactoryBot.define do
  factory :worldwide_office do
    transient do
      title { "Contact title" }
    end
    sequence(:slug) { |index| "worldwide-office-#{index}" }
    contact { create :contact_with_country, title: }
    worldwide_organisation
    worldwide_office_type_id { WorldwideOfficeType.all.sample.id }
  end
end
