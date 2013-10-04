require "test_helper"

class HomeControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test 'Atom feed has the right elements' do
    document = create(:published_news_article)

    get :feed, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', atom_feed_url(format: :atom), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', root_url, 1

      assert_select_atom_entries([document])
    end
  end

  view_test 'Atom feed shows a list of recently published documents' do
    create_published_documents
    draft_documents = create_draft_documents

    get :feed, format: :atom

    documents = Edition.published.in_reverse_chronological_order
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    assert_select_atom_feed do
      assert_select 'feed > updated', text: recent_documents.first.public_timestamp.iso8601

      assert_select_atom_entries(recent_documents)
    end
  end

  view_test 'Atom feed shows a list of recently published documents with govdelivery attributes when requested' do
    editor = create(:departmental_editor)
    edition = create(:published_speech)
    version_2 = edition.create_draft(editor)
    version_2.change_note = 'My new version'
    version_2.publish_as(editor, force: true)

    get :feed, format: :atom, govdelivery_version: 'yes'

    assert_select_atom_feed do
      assert_select_atom_entries([version_2], true)
    end
  end

  view_test "frontend layout includes header-context element to stop breadcrumbs being inserted" do
    get :how_government_works

    assert_select ".header-context"
  end

  view_test "how government works page shows a count of published policies" do
    create(:published_policy)
    create(:draft_policy)

    get :how_government_works

    assert_equal 1, assigns[:policy_count]
    assert_select ".policy-count .count", "1"
  end

  view_test "how government works page shows a count of cabinet ministers, other ministers and total ministers" do
    david_cameron = create(:person, forename: 'David', surname: 'Cameron')
    philip_hammond = create(:person, forename: 'Philip', surname: 'Hammond')
    mark_prisk = create(:person, forename: 'Mark', surname: 'Prisk')
    michael_gove = create(:person, forename: 'Michael', surname: 'Gove')

    prime_minister = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true)
    defence_minister = create(:ministerial_role, name: 'Secretary of State for Defence', cabinet_member: true)
    state_for_housing_minister = create(:ministerial_role, name: 'Minister of State for Housing', cabinet_member: false)
    education_minister = create(:ministerial_role, name: 'Secretary of State for Education', cabinet_member: true)

    create(:ministerial_role_appointment, role: prime_minister, person: david_cameron)
    create(:ministerial_role_appointment, role: defence_minister, person: philip_hammond)
    create(:ministerial_role_appointment, role: state_for_housing_minister, person: mark_prisk)
    create(:ministerial_role_appointment, role: education_minister, person: michael_gove)

    get :how_government_works

    assert_select '.cabinet-ministers .count', '2'
    assert_select '.other-ministers .count', '1'
    assert_select '.all-ministers .count', '4'
  end

  test "get involved has counts of open and closed consultations" do
    old = create(:published_consultation, opening_on: 2.years.ago, closing_on: 1.year.ago - 2.day)

    # open
    recently_opened_consultations = [
      next_closing = create(:open_consultation, opening_on: 9.days.ago, closing_on: 2.days.from_now),
      create(:open_consultation, opening_on: 8.days.ago, closing_on: 3.days.from_now),
      create(:open_consultation, opening_on: 7.days.ago, closing_on: 4.days.from_now),
      create(:open_consultation, opening_on: 6.days.ago, closing_on: 5.days.from_now),
      create(:open_consultation, opening_on: 5.days.ago, closing_on: 6.days.from_now),
    ]

    # closed
    closed_in_past_12_months = create(:published_consultation, opening_on: 2.years.ago, closing_on: 1.year.ago + 1.day)
    create(:closed_consultation, opening_on: 4.days.ago, closing_on: 2.days.ago)
    create(:closed_consultation, opening_on: 3.days.ago, closing_on: 1.day.ago)

    # responded
    recent_outcomes = [
      create(:consultation_with_outcome, opening_on: 2.years.ago, closing_on: 1.year.ago - 8.day),
      create(:consultation_with_outcome, opening_on: 2.years.ago, closing_on: 1.year.ago - 7.day),
      create(:consultation_with_outcome, opening_on: 2.years.ago, closing_on: 1.year.ago - 6.day),
      create(:consultation_with_outcome, opening_on: 2.years.ago, closing_on: 1.year.ago - 5.day),
    ]

    # Add a response ahead of the closing date
    create(:consultation_outcome, consultation: next_closing)

    get :get_involved

    assert_equal recently_opened_consultations.size, assigns[:open_consultation_count]
    assert_equal 3, assigns[:closed_consultation_count]

    # de-reference from the collection decorator
    assert_equal [next_closing], assigns[:next_closing_consultations].object
    assert_equal recently_opened_consultations[-3..-1].reverse, assigns[:recently_opened_consultations].object
    assert_equal recent_outcomes[-3..-1].reverse, assigns[:recent_consultation_outcomes].object
  end

  test 'get involved collects all the take part pages in order' do
    page_3 = create(:take_part_page, ordering: 3)
    page_1 = create(:take_part_page, ordering: 1)
    page_2 = create(:take_part_page, ordering: 2)

    get :get_involved

    assert_equal [page_1, page_2, page_3], assigns(:take_part_pages)
  end

  private

  def create_published_documents
    2.downto(1) do |x|
      create(:published_policy, first_published_at: x.days.ago + 1.hour)
      create(:published_news_article, first_published_at: x.days.ago + 2.hours)
      create(:published_speech, delivered_on: x.days.ago + 3.hours)
      create(:published_publication, first_published_at: x.days.ago + 4.hours)
      create(:published_consultation, opening_on: x.days.ago + 5.hours)
    end
  end

  def create_draft_documents
    [
      create(:draft_policy),
      create(:draft_news_article),
      create(:draft_speech),
      create(:draft_consultation),
      create(:draft_publication)
    ]
  end
end
