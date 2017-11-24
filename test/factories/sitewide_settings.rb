FactoryBot.define do
  factory :sitewide_setting do
    sequence(:key) { |index| "sitewide_setting_key-#{index}" }
    description "Sitewide setting description"
    on false
    govspeak "example text"
  end
end
