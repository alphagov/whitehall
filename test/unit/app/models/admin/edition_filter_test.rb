require "test_helper"

class Admin::EditionFilterTest < ActiveSupport::TestCase
  setup do
    @current_user = build(:gds_editor)
  end

  test "can preload unpublishing data if asked to" do
    news_article = create(:news_article)
    create(:unpublishing, edition: news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_unpublishing: true).editions
    assert_equal news_article, editions.first
    assert editions.first.association(:unpublishing).loaded?
  end

  test "does not preload unpublishing data unless asked to" do
    news_article = create(:news_article)
    create(:unpublishing, edition: news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal news_article, editions.first
    assert_not editions.first.association(:unpublishing).loaded?
  end

  test "can preload last author data if asked to" do
    news_article = create(:news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_last_author: true).editions
    assert_equal news_article, editions.first
    assert editions.first.association(:last_author).loaded?
  end

  test "does not preload last author data unless asked to" do
    news_article = create(:news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal news_article, editions.first
    assert_not editions.first.association(:last_author).loaded?
  end

  test "can preload link check report data if asked to" do
    news_article = create(:news_article)
    create(:link_checker_api_report, link_reportable: news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_link_check_reports: true).editions
    assert_equal news_article, editions.first
    assert editions.first.association(:link_check_reports).loaded?
  end

  test "does not preload link check report data unless asked to" do
    news_article = create(:news_article)
    create(:link_checker_api_report, link_reportable: news_article)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal news_article, editions.first
    assert_not editions.first.association(:last_author).loaded?
  end

  test "ignores invalid state scopes" do
    news_article = create(:draft_news_article)

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, state: "delete_all").editions
    assert_equal [news_article], Edition.all
  end

  test "should filter by edition type" do
    news_article = create(:news_article)
    _another_edition = create(:publication)

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, type: "news_article").editions
  end

  test "should filter by edition state" do
    draft_edition = create(:draft_publication)
    _edition_in_other_state = create(:published_publication)

    assert_equal [draft_edition], Admin::EditionFilter.new(Edition, @current_user, state: "draft").editions
  end

  test "should filter by edition author" do
    author = create(:user)
    edition = create(:publication, authors: [author])
    _edition_by_another_author = create(:publication)

    assert_equal [edition], Admin::EditionFilter.new(Edition, @current_user, author: author.to_param).editions
  end

  test "should filter by organisation" do
    organisation = create(:organisation)
    edition = create(:publication, organisations: [organisation])
    _edition_in_no_organisation = create(:publication)
    _edition_in_another_organisation = create(:publication, organisations: [create(:organisation)])

    assert_equal [edition], Admin::EditionFilter.new(Edition, @current_user, organisation: organisation.to_param).editions
  end

  test "should filter by edition type, state and author" do
    author = create(:user)
    news_article = create(:draft_news_article, authors: [author])
    _another_edition = create(:published_publication, authors: [author])

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, type: "news_article", state: "draft", author: author.to_param).editions
  end

  test "should filter by edition type, state and organisation" do
    organisation = create(:organisation)
    news_article = create(:draft_news_article, organisations: [organisation])
    _another_edition = create(:published_news_article, organisations: [organisation])

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, type: "news_article", state: "draft", organisation: organisation.to_param).editions
  end

  test "should filter by edition type, state and world location" do
    location = create(:world_location)
    news_article = create(:draft_news_article, world_locations: [location])
    _another_edition = create(:published_news_article, world_locations: [location])

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, type: "news_article", state: "draft", world_location: location.id).editions
  end

  test "should filter by world location" do
    location = create(:world_location)
    _consultation = create(:consultation)
    news_article = create(:news_article, world_locations: [location])

    assert_equal [news_article], Admin::EditionFilter.new(Edition, @current_user, world_location: location.id).editions
  end

  test "should filter by user's world locations" do
    location = create(:world_location)
    user = create(:user, world_locations: [location])
    _consultation = create(:consultation)
    news_article = create(:news_article, world_locations: [location])

    assert_equal [news_article], Admin::EditionFilter.new(Edition, user, world_location: "user").editions
  end

  test "should filter by news article sub-type" do
    _news_story   = create(:news_article, news_article_type: NewsArticleType::NewsStory)
    press_release = create(:news_article, news_article_type: NewsArticleType::PressRelease)
    assert_equal [press_release], Admin::EditionFilter.new(Edition, @current_user, type: "news_article_2").editions
  end

  test "should filter by speech sub-type" do
    _transcript    = create(:speech, speech_type: SpeechType::Transcript)
    speaking_notes = create(:speech, speech_type: SpeechType::SpeakingNotes)
    assert_equal [speaking_notes], Admin::EditionFilter.new(Edition, @current_user, type: "speech_3").editions
  end

  test "should filter by publication sub-type" do
    guidance = create(:publication, publication_type: PublicationType::Guidance)
    _form    = create(:publication, publication_type: PublicationType::Form)
    assert_equal [guidance], Admin::EditionFilter.new(Edition, @current_user, type: "publication_#{PublicationType::Guidance.id}").editions
  end

  test "should filter by multiple publication sub-types" do
    guidance     = create(:publication, publication_type: PublicationType::Guidance)
    form         = create(:publication, publication_type: PublicationType::Form)
    policy_paper = create(:publication, publication_type: PublicationType::PolicyPaper)

    assert_same_elements [form, policy_paper],
                         Admin::EditionFilter.new(
                           Edition,
                           @current_user,
                           type: "publication",
                           subtypes: [PublicationType::PolicyPaper.id, PublicationType::Form.id],
                         ).editions

    assert_equal [guidance],
                 Admin::EditionFilter.new(
                   Edition,
                   @current_user,
                   type: "publication",
                   subtypes: [PublicationType::Guidance.id],
                 ).editions
  end

  test "should filter by title" do
    detailed = create(:news_article, title: "Test mcTest")
    _news_article = create(:news_article, title: "A news_article")

    assert_equal [detailed], Admin::EditionFilter.new(Edition, @current_user, title: "test").editions
  end

  test "should filter by date" do
    _older_news_article = create(:draft_news_article, updated_at: 3.days.ago)
    newer_news_article = create(:draft_news_article, updated_at: 1.minute.ago)

    assert_equal [newer_news_article], Admin::EditionFilter.new(Edition, @current_user, from_date: 2.days.ago.to_date.to_fs(:short)).editions
  end

  test "can filter by topical_events" do
    topical_event = create(:topical_event)
    tagged_news   = create(:published_news_article, topical_events: [topical_event])
    _not_tagged   = create(:published_news_article)
    filter        = Admin::EditionFilter.new(Edition, @current_user, topical_event: topical_event.to_param)

    assert_equal [tagged_news], filter.editions
  end

  test "should filter by broken links" do
    edition_with_broken_link = create(
      :published_publication,
    )
    edition_with_caution_link = create(
      :published_publication,
    )
    edition_with_ok_link = create(
      :published_publication,
    )
    edition_with_pending_link = create(
      :published_publication,
    )
    broken_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/broken-link", status: "broken")
    caution_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/caution-link", status: "caution")
    ok_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/ok-link", status: "ok")
    pending_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/pending-link", status: "pending")
    create(:link_checker_api_report, batch_id: 1, link_reportable: edition_with_broken_link, links: [broken_link])
    create(:link_checker_api_report, batch_id: 2, link_reportable: edition_with_caution_link, links: [caution_link])
    create(:link_checker_api_report, batch_id: 3, link_reportable: edition_with_ok_link, links: [ok_link])
    create(:link_checker_api_report, batch_id: 4, link_reportable: edition_with_pending_link, links: [pending_link])

    assert_equal [edition_with_broken_link, edition_with_caution_link], Admin::EditionFilter.new(Edition, @current_user, only_broken_links: true).editions.sort_by(&:id)
  end

  test "should only filter by the most recent broken link report" do
    edition = create(
      :published_publication,
    )
    broken_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/broken-link", status: "broken")
    ok_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/ok-link", status: "ok")
    create(:link_checker_api_report, batch_id: 1, link_reportable: edition, links: [broken_link])
    create(:link_checker_api_report, batch_id: 2, link_reportable: edition, links: [ok_link])

    assert_equal [], Admin::EditionFilter.new(Edition, @current_user, only_broken_links: true).editions.sort_by(&:id)
  end

  test "should return the editions ordered by most recent first" do
    older_news_article = create(:draft_news_article, updated_at: 3.days.ago)
    newer_news_article = create(:draft_news_article, updated_at: 1.minute.ago)

    assert_equal [newer_news_article, older_news_article], Admin::EditionFilter.new(Edition, @current_user, {}).editions
  end

  test "should be invalid if author can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, author: "invalid")
    assert_not filter.valid?
  end

  test "should be invalid if organisation can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, organisation: "invalid")
    assert_not filter.valid?
  end

  test "should generate page title when there are no filter options" do
    filter = Admin::EditionFilter.new(Edition, build(:user))
    assert_equal "Everyone’s documents", filter.page_title
  end

  test "should generate page title when we're displaying active documents" do
    filter = Admin::EditionFilter.new(Edition, build(:user), state: "active")
    assert_equal "Everyone’s documents", filter.page_title
  end

  test "should generate page title when filtering by document state" do
    filter = Admin::EditionFilter.new(Edition, build(:user), state: "draft")
    assert_equal "Everyone’s draft documents", filter.page_title
  end

  test "should generate page title when filtering by document type" do
    filter = Admin::EditionFilter.new(Edition, build(:user), type: "news_article")
    assert_equal "Everyone’s news articles", filter.page_title
  end

  test "should generate page title when filtering by document sub-type" do
    filter = Admin::EditionFilter.new(Edition, build(:user), type: "news_article_1")
    assert_equal "Everyone’s news stories", filter.page_title
  end

  test "should generate page title when filtering by any organisation" do
    organisation = create(:organisation, name: "Cabinet Office")
    filter = Admin::EditionFilter.new(Edition, build(:user), organisation: organisation.to_param)
    assert_equal "Cabinet Office’s documents", filter.page_title
  end

  test "should generate page title when filtering by my organisation" do
    organisation = create(:organisation)
    user = create(:user, organisation:)
    filter = Admin::EditionFilter.new(Edition, user, organisation: organisation.to_param)
    assert_equal "My department’s documents", filter.page_title
  end

  test "should generate page title when filtering by any author" do
    user = create(:user, name: "John Doe")
    filter = Admin::EditionFilter.new(Edition, build(:user), author: user.to_param)
    assert_equal "John Doe’s documents", filter.page_title
  end

  test "should generate page title when filtering by my documents" do
    user = create(:user)
    filter = Admin::EditionFilter.new(Edition, user, author: user.to_param)
    assert_equal "My documents", filter.page_title
  end

  test "should generate page title when filtering by document state, document type and organisation" do
    organisation = create(:organisation, name: "Cabinet Office")
    filter = Admin::EditionFilter.new(Edition, build(:user), state: "published", type: "consultation", organisation: organisation.to_param)
    assert_equal "Cabinet Office’s published consultations", filter.page_title
  end

  test "should generate page title when filtering by document state, document type and author" do
    user = create(:user, name: "John Doe")
    filter = Admin::EditionFilter.new(Edition, build(:user), state: "rejected", type: "speech", author: user.to_param)
    assert_equal "John Doe’s rejected speeches", filter.page_title
  end

  test "should generate page title when filtering by title" do
    filter = Admin::EditionFilter.new(Edition, build(:user), title: "test")
    assert_equal "Everyone’s documents that match ‘test’", filter.page_title
  end

  test "should generate page title when filtering by world location" do
    location = create(:world_location, name: "Spain")
    filter = Admin::EditionFilter.new(Edition, build(:user), world_location: location.to_param)
    assert_equal "Everyone’s documents about Spain", filter.page_title
  end

  test "should generate page title for from date" do
    filter = Admin::EditionFilter.new(Edition, build(:user), from_date: "09/11/2011")
    assert_equal "Everyone’s documents from 09/11/2011", filter.page_title
  end

  test "should generate page title for to date" do
    filter = Admin::EditionFilter.new(Edition, build(:user), to_date: "09/11/2011")
    assert_equal "Everyone’s documents before 09/11/2011", filter.page_title
  end

  test "should paginate editions" do
    3.times { create(:news_article) }
    filter = Admin::EditionFilter.new(Edition, build(:user), per_page: 2)
    assert_equal 2, filter.editions.count
    assert_equal 2, filter.editions.total_pages
  end

  test "editions_for_csv should not be paginated" do
    3.times { create(:news_article) }
    filter = Admin::EditionFilter.new(Edition, build(:user), per_page: 2)
    count = 0
    filter.each_edition_for_csv { |_unused| count += 1 }
    assert_equal 3, count
  end

  test "exportable? if number of editions is below threshold" do
    filter = Admin::EditionFilter.new(Edition, build(:user), per_page: 2)
    filter.stubs(:unpaginated_editions).returns(stub(count: 8000))
    assert filter.exportable?
    filter.stubs(:unpaginated_editions).returns(stub(count: 8001))
    assert_not filter.exportable?
  end
end
