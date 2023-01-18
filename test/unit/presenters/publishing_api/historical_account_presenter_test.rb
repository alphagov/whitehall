require "test_helper"

class PublishingApi::HistoricalAccountPresenterTest < ActiveSupport::TestCase
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

    public_path = "/government/history/past-prime-ministers/some-person"

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      schema_name: "historic_appointment",
      document_type: "historic_appointment",
      title: "Some Person",
      description: "Some summary text",
      locale: "en",
      routes: [
        {
          path: public_path,
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: historical_account.updated_at,
      details: {
        body: Whitehall::GovspeakRenderer.new.govspeak_to_html("Some body text"),
        born: "1900",
        died: "1975",
        interesting_facts: "They were a very interesting person",
        major_acts: "Significant legislation changes",
        political_party: "Labour",
        previous_dates_in_office: "1950 to 1960",
      },
    }

    expected_links = {
      person: [
        historical_account.person.content_id,
      ],
    }

    presenter = PublishingApi::HistoricalAccountPresenter.new(historical_account)

    assert_equal expected_hash, presenter.content
    assert_hash_includes presenter.links, expected_links
    assert_valid_against_publisher_schema(presenter.content, "historic_appointment")
  end
end
