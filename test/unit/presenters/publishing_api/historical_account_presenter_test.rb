require "test_helper"

class PublishingApi::HistoricalAccountPresenterTest < ActiveSupport::TestCase
  test "presents a valid content item" do
    person = create(:person, forename: "Some", surname: "Person")
    role = create(:prime_minister_role)
    create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950), ended_at: Date.civil(1960))
    create(:historic_role_appointment, person:, role: create(:role), started_at: Date.civil(1960), ended_at: Date.civil(1965))
    create(:historic_role_appointment, person:, role:, started_at: Date.civil(1965), ended_at: Date.civil(1970))
    historical_account = create(:historical_account,
                                person:,
                                born: "1900",
                                died: "1975",
                                interesting_facts: "They were a very interesting person",
                                major_acts: "Significant legislation changes",
                                roles: [role])

    person2 = create(:person, forename: "Some Other", surname: "Person")
    create(:historic_role_appointment, person: person2, role:, started_at: Date.civil(1940), ended_at: Date.civil(1950))
    historical_account2 = create(:historical_account, person: person2, roles: [role])

    public_path = "/government/history/past-prime-ministers/some-person"

    expected_hash = {
      base_path: public_path,
      publishing_app: "whitehall",
      rendering_app: "collections",
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
        dates_in_office: [
          {
            start_year: 1950,
            end_year: 1960,
          },
          {
            start_year: 1965,
            end_year: 1970,
          },
        ],
        died: "1975",
        interesting_facts: "They were a very interesting person",
        major_acts: "Significant legislation changes",
        political_party: "Labour",
      },
    }

    expected_links = {
      person: [historical_account.person.content_id],
      ordered_related_items: [person2.historical_accounts.first.content_id],
      parent: %w[db95a864-874f-4f50-a483-352a5bc7ba18],
    }

    PublishingApi::HistoricalAccountPresenter.new(historical_account2)
    presenter = PublishingApi::HistoricalAccountPresenter.new(historical_account)

    assert_equal expected_hash, presenter.content
    assert_hash_includes presenter.links, expected_links
    assert_valid_against_publisher_schema(presenter.content, "historic_appointment")
  end

  test "correctly determines the surrounding historical accounts to present, sorted in descending order" do
    role = create(:prime_minister_role)

    historical_accounts_in_descending_order = (0..7).to_a.map do |i|
      person = create(:person, forename: "Prime Minister #{i}")
      create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950 - i), ended_at: Date.civil(1950 - i))
      create(:historical_account, person:, roles: [role])
    end

    # Related prime ministers for each individual prime minister should be based on a sliding window of the surrounding historical accounts
    expected_indices_of_surrounding_prime_ministers = {
      0 => [1, 2, 3, 4, 5],
      1 => [0, 2, 3, 4, 5],
      2 => [0, 1, 3, 4, 5],
      3 => [0, 1, 2, 4, 5],
      4 => [1, 2, 3, 5, 6],
      5 => [2, 3, 4, 6, 7],
      6 => [2, 3, 4, 5, 7],
      7 => [2, 3, 4, 5, 6],
    }

    historical_accounts_in_descending_order.each_with_index do |historical_account, index|
      links = PublishingApi::HistoricalAccountPresenter.new(historical_account).links
      actual_content_ids_of_related_people = links[:ordered_related_items]
      expected_content_ids_of_related_people = expected_indices_of_surrounding_prime_ministers[index].map do |i|
        historical_accounts_in_descending_order[i].content_id
      end
      assert_equal expected_content_ids_of_related_people, actual_content_ids_of_related_people
    end
  end
end
