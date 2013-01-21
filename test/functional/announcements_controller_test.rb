require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  include DocumentFilterHelpers

  should_be_a_public_facing_controller
  should_return_json_suitable_for_the_document_filter :news_article
  should_return_json_suitable_for_the_document_filter :speech

  test "index should handle badly formatted params for topics and departments" do
    get :index, departments: {"0" => "all"}, topics: {"0" => "all"}
  end

  test "index shows a mix of news and speeches" do
    announced_today = [create(:published_news_article), create(:published_speech)]

    get :index

    assert_select_object announced_today[0]
    assert_select_object announced_today[1]
  end

  test "index sets Cache-Control: max-age to the time of the next scheduled publication" do
    user = login_as(:departmental_editor)
    news = create(:draft_news_article, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    news.schedule_as(user, force: true)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :index
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  test "index shows which type a record is" do
    announced_today = [
      create(:published_news_article, news_article_type: NewsArticleType::NewsStory),
      create(:published_speech),
      create(:published_speech, speech_type: SpeechType::WrittenStatement),
    ]

    get :index

    assert_select_object announced_today[0] do
      assert_select ".announcement_type", text: "News story"
    end
    assert_select_object announced_today[1] do
      assert_select ".announcement_type", text: "Speech"
    end
    assert_select_object announced_today[2] do
      assert_select ".announcement_type", text: "Statement to parliament"
    end
  end

  test "index shows the date on which a speech was delivered" do
    delivered_on = Date.parse("1999-12-31")
    speech = create(:published_speech, delivered_on: delivered_on)

    get :index

    assert_select_object(speech) do
     assert_select "abbr.public_timestamp[title=?]", delivered_on.to_datetime.iso8601
    end
  end

  test "index shows the time when a news article was first published" do
    first_published_at = Time.zone.parse("2001-01-01 01:01")
    news_article = create(:published_news_article, first_published_at: first_published_at)

    get :index

    assert_select_object(news_article) do
     assert_select "abbr.public_timestamp[title=?]", first_published_at.iso8601
    end
  end

  test "index shows related organisations for each type of article" do
    first_org = create(:organisation, name: 'first-org', acronym: "FO")
    second_org = create(:organisation, name: 'second-org', acronym: "SO")
    news_article = create(:published_news_article, first_published_at: 4.days.ago, organisations: [first_org, second_org])
    role = create(:ministerial_role, organisations: [second_org])
    role_appointment = create(:ministerial_role_appointment, role: role)
    speech = create(:published_speech, delivered_on: 5.days.ago, role_appointment: role_appointment)

    get :index

    assert_select_object news_article do
      assert_select ".organisations", text: "#{first_org.acronym} and #{second_org.acronym}", count: 1
    end

    assert_select_object speech do
      assert_select ".organisations", text: second_org.acronym, count: 1
    end
  end

  test "index shows articles in reverse chronological order" do
    oldest = create(:published_speech, delivered_on: 5.days.ago)
    newest = create(:published_news_article, first_published_at: 4.days.ago)

    get :index

    assert_select "#{record_css_selector(newest)} + #{record_css_selector(oldest)}"
  end

  test "index shows articles in chronological order if date filter is 'after' a given date" do
    oldest = create(:published_speech, delivered_on: 5.days.ago)
    newest = create(:published_news_article, first_published_at: 4.days.ago)

    get :index, direction: 'after', date: 6.days.ago.to_s

    assert_select "#{record_css_selector(oldest)} + #{record_css_selector(newest)}"
  end

  test "index shows selected announcement type filter option in the title" do
    get :index, announcement_type_option: 'news-stories'

    assert_select 'h1 span', ': News stories'
  end

  test "index indicates selected announcement type filter option in the filter selector" do
    get :index, announcement_type_option: 'news-stories'

    assert_select "select[name='announcement_type_option']" do
      assert_select "option[selected='selected']", text: Whitehall::AnnouncementFilterOption::NewsStory.label
    end
  end

  def assert_documents_appear_in_order_within(containing_selector, expected_documents)
    articles = css_select "#{containing_selector} tr.document-row"
    expected_document_ids = expected_documents.map { |doc| dom_id(doc) }
    actual_document_ids = articles.map { |a| a["id"] }
    assert_equal expected_document_ids, actual_document_ids
  end

  test "index shows only the first page of news articles or speeches" do
    news = (1..2).map { |n| create(:published_news_article, first_published_at: n.days.ago) }
    speeches = (3..4).map { |n| create(:published_speech, delivered_on: n.days.ago) }

    with_number_of_documents_per_page(3) do
      get :index
    end

    assert_documents_appear_in_order_within("#announcements-container", news + speeches[0..0])
    (speeches[1..2]).each do |speech|
      refute_select_object(speech)
    end
  end

  test "index shows the requested page" do
    news = (1..3).map { |n| create(:published_news_article, first_published_at: n.days.ago) }
    speeches = (4..6).map { |n| create(:published_speech, delivered_on: n.days.ago) }

    with_number_of_documents_per_page(4) do
      get :index, page: 2
    end

    assert_documents_appear_in_order_within("#announcements-container", speeches[1..2])
    (news + speeches[0..0]).each do |speech|
      refute_select_object(speech)
    end
  end

  test 'index has atom feed autodiscovery link' do
    get :index
    assert_select_autodiscovery_link announcements_url(format: "atom")
  end

  test 'index atom feed autodiscovery link includes any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, topics: [topic], departments: [organisation]

    assert_select_autodiscovery_link announcements_url(format: "atom", topics: [topic], departments: [organisation])
  end

  test "index generates an atom feed for the current filter" do
    org = create(:organisation, name: "org-name")

    get :index, format: :atom, departments: [org.to_param]

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml',
                    announcements_url(format: :atom, departments: [org.to_param]), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', root_url, 1
    end
  end

  test "index generates an atom feed with entries for announcements matching the current filter" do
    org = create(:organisation, name: "org-name")
    other_org = create(:organisation, name: "other-org")
    news = create(:published_news_article, organisations: [org], first_published_at: 1.week.ago)
    speech = create(:published_speech, organisations: [other_org], delivered_on: 3.days.ago)

    get :index, format: :atom, departments: [org.to_param]

    assert_select_atom_feed do
      assert_select_atom_entries([news])
    end
  end

  test "index generates an atom feed with summary content and prefixed title entries for announcements matching the current filter when requested" do
    org = create(:organisation, name: "org-name")
    other_org = create(:organisation, name: "other-org")
    news = create(:published_news_article, organisations: [org], first_published_at: 1.week.ago)
    speech = create(:published_speech, organisations: [other_org], delivered_on: 3.days.ago)

    get :index, format: :atom, departments: [org.to_param], govdelivery_version: 'on'

    assert_select_atom_feed do
      assert_select_atom_entries([news], :summary)
    end
  end

  test 'index atom feed should return a valid feed if there are no matching documents' do
    get :index, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > updated', text: Time.zone.now.iso8601
      assert_select 'feed > entry', count: 0
    end
  end
end
