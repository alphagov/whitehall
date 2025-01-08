FactoryBot.define do
  factory :worldwide_office do
    transient do
      title { "Contact title" }
      translated_into { nil }
    end
    sequence(:slug) { |index| "worldwide-office-#{index}" }
    content_id { SecureRandom.uuid }
    contact { create :contact_with_country, title:, translated_into: }
    edition { create :worldwide_organisation }
    worldwide_office_type_id { WorldwideOfficeType.all.sample.id }
  end
end
