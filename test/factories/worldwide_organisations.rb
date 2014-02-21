FactoryGirl.define do
  factory :worldwide_organisation, traits: [:translated] do
    sequence(:name) { |index| "worldwide-organisation-#{index}" }
    summary "summary"
    description "description"

    trait(:with_sponsorships) {
      after :create do |organisation, evaluator|
        FactoryGirl.create(:sponsorship, worldwide_organisation: organisation)
      end
    }
  end
end
