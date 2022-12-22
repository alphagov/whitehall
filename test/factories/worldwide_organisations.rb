FactoryBot.define do
  factory :worldwide_organisation, traits: [:translated] do
    sequence(:name) { |index| "worldwide-organisation-#{index}" }

    trait(:with_office) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:worldwide_office, worldwide_organisation: organisation)
      end
    end

    trait(:with_social_media_accounts) do
      after :create do |organisation, _evaluator|
        social_media_service = create(:social_media_service, name: "Facebook")
        social_media_account = create(:social_media_account, title: "Our Facebook Page", url: "https://www.facebook.com/UKgovernment", social_media_service:)
        organisation.social_media_accounts << social_media_account
      end
    end

    trait(:with_sponsorships) do
      after :create do |organisation, _evaluator|
        FactoryBot.create(:sponsorship, worldwide_organisation: organisation)
      end
    end

    trait(:with_world_location) do
      after :create do |worldwide_organisation, _evaluator|
        worldwide_organisation.world_locations << FactoryBot.create(:world_location)
      end
    end
  end
end
