FactoryBot.define do
  factory :offsite_link do
    title { "Summary text" }
    link_type { "alert" }
    summary { "Summary text" }
    url { "http://gov.uk/test" }
  end

  trait :for_topical_event do
    topical_events { FactoryBot.build_list(:topical_event, 1) }
  end

  trait :for_world_location_news do
    world_location_news { FactoryBot.build_list(:world_location_news, 1) }
  end

  trait :for_organisation do
    organisations { FactoryBot.build_list(:organisation, 1) }
  end

  trait :for_standard_edition do
    editions { FactoryBot.build_list(:edition, 1) }
  end
end
