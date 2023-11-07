require "test_helper"

class PublishingApi::HistoricalAccountIndexPresenterTest < ActiveSupport::TestCase
  setup do
    person = create(:person, forename: "Some", surname: "Person")
    @role = create(:prime_minister_role)
    create(:historic_role_appointment, person:, role: @role, started_at: Date.civil(1950), ended_at: Date.civil(1960))
    @historical_account = create(:historical_account,
                                 person:,
                                 born: "1900",
                                 died: "1975",
                                 interesting_facts: "They were a very interesting person",
                                 major_acts: "Significant legislation changes",
                                 role: @role)
  end

  test "presents a valid content item" do
    expected_hash = {
      base_path: "/government/history/past-prime-ministers",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "collections",
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
      public_updated_at: @historical_account.updated_at,
      details: {
        appointments_without_historical_accounts: [],
      },
    }

    expected_links = {
      historical_accounts: [@historical_account.content_id],
    }

    presenter = PublishingApi::HistoricalAccountsIndexPresenter.new

    assert_equal expected_hash, presenter.content
    assert presenter.links, expected_links
    assert_valid_against_publisher_schema(presenter.content, "historic_appointments")
  end

  test "when a historic role appointment does not yet have a historic account created, presents these in the details hash" do
    person_without_historic_account = create(:person, :with_image, forename: "A", surname: "Person without a historic account yet")
    create(:historic_role_appointment, person: person_without_historic_account, role: @role, started_at: Date.civil(1960), ended_at: Date.civil(1970))
    create(:historic_role_appointment, person: person_without_historic_account, role: @role, started_at: Date.civil(1990), ended_at: Date.civil(2000))
    create(:historic_role_appointment, person: person_without_historic_account, role: create(:role), started_at: Date.civil(1970), ended_at: Date.civil(1980))
    create(:role_appointment, person: person_without_historic_account, role: @role, started_at: Date.civil(2001), ended_at: nil)

    expected_links = {
      historical_accounts: [@historical_account.content_id],
      parent: [PublishingApi::HistoricalAccountsIndexPresenter::HISTORY_OF_THE_UK_GOVERNMENT_CONTENT_ID],
    }

    expected_details = {
      appointments_without_historical_accounts: [
        {
          title: "A Person without a historic account yet",
          dates_in_office: [
            {
              start_year: 1960,
              end_year: 1970,
            },
            {
              start_year: 1990,
              end_year: 2000,
            },

          ],
          image: {
            url: person_without_historic_account.image.url,
            alt_text: "A Person without a historic account yet",
          },
        },
      ],
    }

    presenter = PublishingApi::HistoricalAccountsIndexPresenter.new

    assert_equal expected_details, presenter.content[:details]
    assert_valid_against_publisher_schema(presenter.content, "historic_appointments")
    assert_equal presenter.links, expected_links
    assert_valid_against_links_schema({ links: presenter.links }, "historic_appointments")
  end

  test "when a role appointment is current, does not present these in the details hash" do
    person_without_historic_account = create(:person, forename: "A", surname: "Person without a historic account yet")
    create(:role_appointment, person: person_without_historic_account, role: @role, started_at: Date.civil(2001), ended_at: nil)

    expected_details = { appointments_without_historical_accounts: [] }

    actual_details = PublishingApi::HistoricalAccountsIndexPresenter.new.content[:details]

    assert_equal expected_details, actual_details
  end

  test "it filters out people images with missing assets" do
    person_without_historic_account = build(:person, :with_image, forename: "A", surname: "Person without a historic account yet")
    person_without_historic_account.image.assets = []
    person_without_historic_account.save!
    create(:role_appointment, person: person_without_historic_account, role: @role, started_at: Date.civil(2001), ended_at: Date.civil(2002))

    expected_details = { appointments_without_historical_accounts: [
      {
        title: "A Person without a historic account yet",
        dates_in_office: [{ start_year: 2001, end_year: 2002 }],
      },
    ] }

    actual_details = PublishingApi::HistoricalAccountsIndexPresenter.new.content[:details]

    assert_equal expected_details, actual_details
  end
end
