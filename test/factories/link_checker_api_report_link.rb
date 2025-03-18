FactoryBot.define do
  factory :link_checker_api_report_link, class: LinkCheckerApiReport::Link do
    uri { "http://www.example.com" }
    status { "ok" }
    ordering { 0 }

    trait :broken do
      status { "broken" }
    end

    trait :danger do
      status { "danger" }
    end
  end
end
