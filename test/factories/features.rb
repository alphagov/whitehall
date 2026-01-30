FactoryBot.define do
  factory :feature do
    document

    image { build(:featured_image_data) }

    trait :with_topical_event_association do
      topical_event
      document { nil }
    end

    trait :with_offsite_link_association do
      association :offsite_link, :for_organisation
      document { nil }
    end
  end
end
