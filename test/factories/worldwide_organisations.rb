FactoryBot.define do
  factory :worldwide_organisation, traits: [:translated] do
    sequence(:name) { |index| "worldwide-organisation-#{index}" }

    trait(:with_sponsorships) {
      after :create do |organisation, evaluator|
        FactoryBot.create(:sponsorship, worldwide_organisation: organisation)
      end
    }
  end
end
