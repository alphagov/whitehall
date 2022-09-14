FactoryBot.define do
  factory :offsite_link do
    association :parent, factory: :organisation
    title { "Summary text" }
    link_type { "alert" }
    summary { "Summary text" }
    url { "http://gov.uk/test" }
  end
end
