FactoryBot.define do
  factory :link_checker_api_report do
    batch_id { 1 }
    status { "in_progress" }
    edition do
      create(:draft_edition, body: "Includes a [link](http://www.example.com)")
    end
    links do
      [
        create(:link_checker_api_report_link, uri: "http://www.example.com", ordering: 0),
        create(:link_checker_api_report_link, uri: "http://www.example.org", ordering: 0),
      ]
    end
  end

  factory :link_checker_api_report_completed, class: LinkCheckerApiReport do
    batch_id { 1 }
    status { "completed" }
    edition do
      create(:draft_edition, body: "Includes a [link](http://www.example.com)")
    end
    links do
      [
        create(:link_checker_api_report_link, uri: "http://www.example.com", ordering: 0),
        create(:link_checker_api_report_link, uri: "http://www.example.org", ordering: 0),
      ]
    end
  end
end
