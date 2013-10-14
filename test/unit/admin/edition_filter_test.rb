require 'test_helper'

class Admin::EditionFilterTest < ActiveSupport::TestCase
  setup do
    @current_user = build(:gds_editor)
  end

  test "should filter by edition type" do
    policy = create(:policy)
    another_edition = create(:publication)

    assert_equal [policy], Admin::EditionFilter.new(Edition, @current_user, type: 'policy').editions
  end

  test "should filter by edition state" do
    draft_edition = create(:draft_policy)
    edition_in_other_state = create(:published_policy)

    assert_equal [draft_edition], Admin::EditionFilter.new(Edition, @current_user, state: 'draft').editions
  end

  test "should filter by edition author" do
    author = create(:user)
    edition = create(:policy, authors: [author])
    edition_by_another_author = create(:policy)

    assert_equal [edition], Admin::EditionFilter.new(Edition, @current_user, author: author.to_param).editions
  end

  test "should filter by organisation" do
    organisation = create(:organisation)
    edition = create(:policy, organisations: [organisation])
    edition_in_no_organisation = create(:policy)
    edition_in_another_organisation = create(:publication, organisations: [create(:organisation)])

    assert_equal [edition], Admin::EditionFilter.new(Edition, @current_user, organisation: organisation.to_param).editions
  end

  test "should filter by edition type, state and author" do
    author = create(:user)
    policy = create(:draft_policy, authors: [author])
    another_edition = create(:published_policy, authors: [author])

    assert_equal [policy], Admin::EditionFilter.new(Edition, @current_user, type: 'policy', state: 'draft', author: author.to_param).editions
  end

  test "should filter by edition type, state and organisation" do
    organisation = create(:organisation)
    policy = create(:draft_policy, organisations: [organisation])
    another_edition = create(:published_policy, organisations: [organisation])

    assert_equal [policy], Admin::EditionFilter.new(Edition, @current_user, type: 'policy', state: 'draft', organisation: organisation.to_param).editions
  end

  test "should filter by edition type, state and world location" do
    location = create(:world_location)
    policy = create(:draft_policy, world_locations: [location])
    another_edition = create(:published_policy, world_locations: [location])

    assert_equal [policy], Admin::EditionFilter.new(Edition, @current_user, type: 'policy', state: 'draft', world_location: location.id).editions
  end

  test "should filter by world location" do
    location = create(:world_location)
    consultation = create(:consultation)
    policy = create(:policy, world_locations: [location])

    assert_equal [policy], Admin::EditionFilter.new(Edition, @current_user, world_location: location.id).editions
  end

  test "should filter by user's world locations" do
    location = create(:world_location)
    user = create(:user, world_locations: [location])
    consultation = create(:consultation)
    policy = create(:policy, world_locations: [location])

    assert_equal [policy], Admin::EditionFilter.new(Edition, user, world_location: "user").editions
  end

  test "should filter by world location news article" do
    world_location_news_article = create(:world_location_news_article)
    assert_equal [world_location_news_article], Admin::EditionFilter.new(Edition, @current_user, type: 'world_location_news_article').editions
  end

  test "should filter by news article sub-type" do
    news_story    = create(:news_article, news_article_type: NewsArticleType::NewsStory)
    press_release = create(:news_article, news_article_type: NewsArticleType::PressRelease)
    assert_equal [press_release], Admin::EditionFilter.new(Edition, @current_user, type: 'news_article_2').editions
  end

  test "should filter by speech sub-type" do
    transcript     = create(:speech, speech_type: SpeechType::Transcript)
    speaking_notes = create(:speech, speech_type: SpeechType::SpeakingNotes)
    assert_equal [speaking_notes], Admin::EditionFilter.new(Edition, @current_user, type: 'speech_3').editions
  end

  test "should filter by publication sub-type" do
    national_statistics = create(:publication, publication_type: PublicationType::NationalStatistics)
    form                = create(:publication, publication_type: PublicationType::Form)
    assert_equal [national_statistics], Admin::EditionFilter.new(Edition, @current_user, type: 'publication_15').editions
  end

  test "should filter by title" do
    detailed = create(:policy, title: "Test mcTest")
    policy = create(:policy, title: "A policy")

    assert_equal [detailed], Admin::EditionFilter.new(Edition, @current_user, title: "test").editions
  end

  test "should filter by date" do
    older_policy = create(:draft_policy, updated_at: 3.days.ago)
    newer_policy = create(:draft_policy, updated_at: 1.minute.ago)

    assert_equal [newer_policy], Admin::EditionFilter.new(Edition, @current_user, from_date: 2.days.ago.to_date.to_s(:short)).editions
  end

  test "should return the editions ordered by most recent first" do
    older_policy = create(:draft_policy, updated_at: 3.days.ago)
    newer_policy = create(:draft_policy, updated_at: 1.minute.ago)

    assert_equal [newer_policy, older_policy], Admin::EditionFilter.new(Edition, @current_user, {}).editions
  end

  test "should be invalid if author can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, author: 'invalid')
    refute filter.valid?
  end

  test "should be invalid if organisation can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, organisation: 'invalid')
    refute filter.valid?
  end

  test "should generate page title when there are no filter options" do
    filter = Admin::EditionFilter.new(Edition, build(:user))
    assert_equal "Everyone's documents", filter.page_title
  end

  test "should generate page title when we're displaying active documents" do
    filter = Admin::EditionFilter.new(Edition, build(:user), state: 'active')
    assert_equal "Everyone's documents", filter.page_title
  end

  test "should generate page title when filtering by document state" do
    filter = Admin::EditionFilter.new(Edition, build(:user), state: 'draft')
    assert_equal "Everyone's draft documents", filter.page_title
  end

  test "should generate page title when filtering by document type" do
    filter = Admin::EditionFilter.new(Edition, build(:user), type: 'news_article')
    assert_equal "Everyone's news articles", filter.page_title
  end

  test "should generate page title when filtering by document sub-type" do
    filter = Admin::EditionFilter.new(Edition, build(:user), type: 'news_article_1')
    assert_equal "Everyone's news stories", filter.page_title
  end

  test "should generate page title when filtering by any organisation" do
    organisation = create(:organisation, name: "Cabinet Office")
    filter = Admin::EditionFilter.new(Edition, build(:user), organisation: organisation.to_param)
    assert_equal "Cabinet Office's documents", filter.page_title
  end

  test "should generate page title when filtering by my organisation" do
    organisation = create(:organisation)
    user = create(:user, organisation: organisation)
    filter = Admin::EditionFilter.new(Edition, user, organisation: organisation.to_param)
    assert_equal "My department's documents", filter.page_title
  end

  test "should generate page title when filtering by any author" do
    user = create(:user, name: 'John Doe')
    filter = Admin::EditionFilter.new(Edition, build(:user), author: user.to_param)
    assert_equal "John Doe's documents", filter.page_title
  end

  test "should generate page title when filtering by my documents" do
    user = create(:user)
    filter = Admin::EditionFilter.new(Edition, user, author: user.to_param)
    assert_equal "My documents", filter.page_title
  end

  test "should generate page title when filtering by document state, document type and organisation" do
    organisation = create(:organisation, name: 'Cabinet Office')
    filter = Admin::EditionFilter.new(Edition, build(:user), state: 'published', type: 'consultation', organisation: organisation.to_param)
    assert_equal "Cabinet Office's published consultations", filter.page_title
  end

  test "should generate page title when filtering by document state, document type and author" do
    user = create(:user, name: 'John Doe')
    filter = Admin::EditionFilter.new(Edition, build(:user), state: 'rejected', type: 'speech', author: user.to_param)
    assert_equal "John Doe's rejected speeches", filter.page_title
  end

  test "should generate page title when filtering by title" do
    filter = Admin::EditionFilter.new(Edition, build(:user), title: 'test')
    assert_equal "Everyone's documents that match 'test'", filter.page_title
  end

  test "should generate page title when filtering by world location" do
    location = create(:world_location, name: 'Spain')
    filter = Admin::EditionFilter.new(Edition, build(:user), world_location: location.to_param)
    assert_equal "Everyone's documents about Spain", filter.page_title
  end

  test "should generate page title for from date" do
    filter = Admin::EditionFilter.new(Edition, build(:user), from_date: '09/11/2011')
    assert_equal "Everyone's documents after 09/11/2011", filter.page_title
  end

  test "should generate page title for to date" do
    filter = Admin::EditionFilter.new(Edition, build(:user), to_date: '09/11/2011')
    assert_equal "Everyone's documents before 09/11/2011", filter.page_title
  end
end
