require "test_helper"

class PublishingApi::HistoricalAccountIndexPresenterTest < ActiveSupport::TestCase
  test "presents a valid content item" do
    person = create(:person, forename: "Some", surname: "Person")
    role = create(:prime_minister_role)
    create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950), ended_at: Date.civil(1960))
    historical_account = create(:historical_account,
                                person:,
                                born: "1900",
                                died: "1975",
                                interesting_facts: "They were a very interesting person",
                                major_acts: "Significant legislation changes",
                                roles: [role])

    expected_hash = {
      base_path: "/government/history/past-prime-ministers",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "historic_appointments",
      document_type: "historic_appointments",
      title: "Past Prime Ministers",
      locale: "en",
      routes: [
        {
          path: "/government/history/past-prime-ministers",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: historical_account.updated_at,
      details: {},
    }

    expected_links = {
      historical_accounts: [historical_account.content_id],
    }

    presenter = PublishingApi::HistoricalAccountsIndexPresenter.new

    assert_equal expected_hash, presenter.content
    assert_hash_includes presenter.links, expected_links
    assert_valid_against_publisher_schema(presenter.content, "historic_appointments")
  end
end
