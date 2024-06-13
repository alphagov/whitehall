FactoryBot.define do
  factory :topical_event_about_page do
    sequence(:name) { |index| "topical-event-about-page-#{index}" }
    read_more_link_text { "Read more" }
    summary { "Summary" }
    body { "Body" }
    topical_event
  end
end
