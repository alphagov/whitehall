require "test_helper"

class Admin::EditionFilterTest < ActiveSupport::TestCase
  setup do
    @current_user = build(:gds_editor)
  end

  test "should return limited access editions when the edition is published by the users organisation" do
    user = create(:user)
    edition = create(
      :publication,
      access_limited: true,
    )
    edition.organisations.first.users << user

    filter = Admin::EditionFilter.new(Edition, user)
    assert_equal edition, filter.editions.first
  end

  test "should not return editions which have limited access for other orgs for non-gds admins" do
    create(:publication, access_limited: true)

    filter = Admin::EditionFilter.new(Edition, build(:user))
    assert_equal 0, filter.editions.count
  end

  test "should return limited access editions for GDS admins" do
    edition = create(:publication, access_limited: true)

    filter = Admin::EditionFilter.new(Edition, build(:gds_admin))
    assert_equal edition, filter.editions.first
  end

  test "can preload unpublishing data if asked to" do
    publication = create(:publication)
    create(:unpublishing, edition: publication)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_unpublishing: true).editions
    assert_equal publication, editions.first
    assert editions.first.association(:unpublishing).loaded?
  end

  test "does not preload unpublishing data unless asked to" do
    publication = create(:publication)
    create(:unpublishing, edition: publication)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal publication, editions.first
    assert_not editions.first.association(:unpublishing).loaded?
  end

  test "can preload last author data if asked to" do
    publication = create(:publication)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_last_author: true).editions
    assert_equal publication, editions.first
    assert editions.first.association(:last_author).loaded?
  end

  test "does not preload last author data unless asked to" do
    publication = create(:publication)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal publication, editions.first
    assert_not editions.first.association(:last_author).loaded?
  end

  test "can preload link check report data if asked to" do
    publication = create(:publication)
    create(:link_checker_api_report, edition: publication)

    editions = Admin::EditionFilter.new(Edition, @current_user, include_link_check_report: true).editions
    assert_equal publication, editions.first
    assert editions.first.association(:link_check_report).loaded?
  end

  test "does not preload link check report data unless asked to" do
    publication = create(:publication)
    create(:link_checker_api_report, edition: publication)

    editions = Admin::EditionFilter.new(Edition, @current_user).editions
    assert_equal publication, editions.first
    assert_not editions.first.association(:last_author).loaded?
  end

  test "ignores invalid state scopes" do
    publication = create(:draft_publication)

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, state: "delete_all").editions
    assert_equal [publication], Edition.all
  end

  test "should filter by edition type" do
    publication = create(:publication)
    _another_edition = create(:speech)

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, type: "publication").editions
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
    publication = create(:draft_publication, authors: [author])
    _another_edition = create(:published_publication, authors: [author])

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, type: "publication", state: "draft", author: author.to_param).editions
  end

  test "should filter by edition type, state and organisation" do
    organisation = create(:organisation)
    publication = create(:draft_publication, organisations: [organisation])
    _another_edition = create(:published_publication, organisations: [organisation])

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, type: "publication", state: "draft", organisation: organisation.to_param).editions
  end

  test "should filter by edition type, state and world location" do
    location = create(:world_location)
    publication = create(:draft_speech, world_locations: [location])
    _another_edition = create(:published_speech, world_locations: [location])

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, type: "speech", state: "draft", world_location: location.id).editions
  end

  test "should filter by world location" do
    location = create(:world_location)
    _consultation = create(:consultation)
    publication = create(:publication, world_locations: [location])

    assert_equal [publication], Admin::EditionFilter.new(Edition, @current_user, world_location: location.id).editions
  end

  test "should filter by user's world locations" do
    location = create(:world_location)
    user = create(:user, world_locations: [location])
    _consultation = create(:consultation)
    publication = create(:publication, world_locations: [location])

    assert_equal [publication], Admin::EditionFilter.new(Edition, user, world_location: "user").editions
  end

  test "should filter by StandardEdition type" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(:draft_standard_edition)

    assert_equal [edition], Admin::EditionFilter.new(Edition, @current_user, type: "test_type").editions
  end

  test "should filter by standard edition group type" do
    news_story_document_type = build_configurable_document_type("type_one", { "settings" => { "configurable_document_group" => "news_article_group" } })
    press_release_document_type = build_configurable_document_type("type_two", { "settings" => { "configurable_document_group" => "news_article_group" } })
    subtypes = news_story_document_type.merge(press_release_document_type)
    ConfigurableDocumentType.setup_test_types(subtypes)

    config_driven_type_one_document = create(:draft_standard_edition, configurable_document_type: "type_one")
    config_driven_type_two_document = create(:draft_standard_edition, configurable_document_type: "type_two")

    assert_equal [config_driven_type_one_document, config_driven_type_two_document], Admin::EditionFilter.new(Edition, @current_user, type: "news_article_group").editions.sort_by(&:id)
  end

  test "should filter by speech sub-type" do
    _transcript    = create(:speech, speech_type: SpeechType::Transcript)
    speaking_notes = create(:speech, speech_type: SpeechType::SpeakingNotes)
    assert_equal [speaking_notes], Admin::EditionFilter.new(Edition, @current_user, type: "speaking_notes").editions
  end

  test "should filter by publication sub-type" do
    guidance = create(:publication, publication_type: PublicationType::Guidance)
    _form    = create(:publication, publication_type: PublicationType::Form)
    assert_equal [guidance], Admin::EditionFilter.new(Edition, @current_user, type: "guidance").editions
  end

  test "should match both 'StandardEdition' type and sub-type (of 'concrete' model) of the same name" do
    configurable_document_type = build_configurable_document_type("written_statement")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    standard_edition = create(:draft_standard_edition, configurable_document_type: "written_statement")
    speech = create(:speech, speech_type: SpeechType::WrittenStatement)

    assert_equal(
      [standard_edition, speech].map(&:id).sort,
      Admin::EditionFilter.new(Edition, @current_user, type: "written_statement").editions.map(&:id).sort,
    )
  end

  test "should filter by title" do
    detailed = create(:publication, title: "Test mcTest")
    _publication = create(:publication, title: "A publication")

    assert_equal [detailed], Admin::EditionFilter.new(Edition, @current_user, title: "test").editions
  end

  test "should filter by date" do
    _older_publication = create(:draft_publication, updated_at: 3.days.ago)
    newer_publication = create(:draft_publication, updated_at: 1.minute.ago)

    assert_equal [newer_publication], Admin::EditionFilter.new(Edition, @current_user, from_date: 2.days.ago.to_date.to_fs(:short)).editions
  end

  test "can filter by topical_events" do
    topical_event = create(:topical_event)
    tagged_news   = create(:published_publication, topical_events: [topical_event])
    _not_tagged   = create(:published_publication)
    filter        = Admin::EditionFilter.new(Edition, @current_user, topical_event: topical_event.to_param)

    assert_equal [tagged_news], filter.editions
  end

  test "should filter by invalid, non-superseded editions" do
    # rubocop:disable Lint/UselessAssignment
    valid_draft_edition = create(:draft_edition, revalidated_at: Time.zone.now)
    valid_published_edition = create(:published_edition, revalidated_at: Time.zone.now)
    invalid_draft_edition = create(:draft_edition, revalidated_at: nil)
    invalid_published_edition = create(:published_edition, revalidated_at: nil)
    invalid_superseded_edtion = create(:superseded_edition, revalidated_at: nil)
    # rubocop:enable Lint/UselessAssignment

    assert_equal(
      [invalid_draft_edition, invalid_published_edition],
      Admin::EditionFilter.new(Edition, @current_user, only_invalid_editions: true).editions.sort_by(&:id),
    )
  end

  test "should filter by editions not validated since X" do
    # rubocop:disable Lint/UselessAssignment
    edition_validated_recently = create(:draft_edition, revalidated_at: Time.zone.now)
    edition_validated_ages_ago = create(:published_edition, revalidated_at: 1.year.ago)
    edition_never_validated = create(:draft_edition, revalidated_at: nil)
    # rubocop:enable Lint/UselessAssignment

    assert_equal(
      [edition_validated_ages_ago, edition_never_validated],
      Admin::EditionFilter.new(Edition, @current_user, not_validated_since: 1.week.ago.strftime("%d/%m/%Y")).editions.sort_by(&:id),
    )
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
    edition_with_danger_link = create(
      :published_publication,
    )
    broken_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/broken-link", status: "broken")
    caution_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/caution-link", status: "caution")
    ok_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/ok-link", status: "ok")
    pending_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/pending-link", status: "pending")
    danger_link = create(:link_checker_api_report_link, uri: "https://www.gov.uk/danger-link", status: "danger")
    create(:link_checker_api_report, batch_id: 1, edition: edition_with_broken_link, links: [broken_link])
    create(:link_checker_api_report, batch_id: 2, edition: edition_with_caution_link, links: [caution_link])
    create(:link_checker_api_report, batch_id: 3, edition: edition_with_ok_link, links: [ok_link])
    create(:link_checker_api_report, batch_id: 4, edition: edition_with_pending_link, links: [pending_link])
    create(:link_checker_api_report, batch_id: 5, edition: edition_with_danger_link, links: [danger_link])

    assert_equal [edition_with_broken_link, edition_with_caution_link, edition_with_danger_link], Admin::EditionFilter.new(Edition, @current_user, only_broken_links: true).editions.sort_by(&:id)
  end

  test "should filter by overdue reviews" do
    document = create(:document)
    edition_with_overdue_reminder = create(:published_edition, document:)
    create(:review_reminder, :reminder_due, document:)
    create(:published_edition)

    assert_equal [edition_with_overdue_reminder], Admin::EditionFilter.new(Edition, @current_user, review_overdue: true).editions
  end

  test "should filter by linked documents" do
    topical_event_type = build_configurable_document_type("topical_event", { "settings" => { "features_enabled" => true } })
    test_type_with_topical_event_association = build_configurable_document_type("test_type", { "associations" => [
      {
        "key" => "topical_event_documents",
      },
    ] })
    ConfigurableDocumentType.setup_test_types(topical_event_type.merge(test_type_with_topical_event_association))

    featuring_edition = create(
      :published_standard_edition,
      :with_organisations,
      configurable_document_type: "topical_event",
    )

    linked_edition = create(:published_standard_edition, :with_organisations, configurable_document_type: "test_type", topical_event_documents: [featuring_edition.document])
    create(:published_standard_edition, :with_organisations, configurable_document_type: "test_type")

    filtered_editions = Admin::EditionFilter.new(Edition, @current_user, linked_document: featuring_edition.document).editions

    assert_equal [linked_edition], filtered_editions
  end

  test "should return the editions ordered by most recent first" do
    older_publication = create(:draft_publication, updated_at: 3.days.ago)
    newer_publication = create(:draft_publication, updated_at: 1.minute.ago)

    assert_equal [newer_publication, older_publication], Admin::EditionFilter.new(Edition, @current_user, {}).editions
  end

  test "should be invalid if author can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, author: "invalid")
    assert_not filter.valid?
    assert_equal 1, filter.errors.count
    assert_includes filter.errors, "Author not found"
  end

  test "should be invalid if organisation can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, organisation: "invalid")
    assert_not filter.valid?
    assert_equal 1, filter.errors.count
    assert_includes filter.errors, "Organisation not found"
  end

  test "should be invalid if organisation and author can't be found" do
    filter = Admin::EditionFilter.new(Edition, @current_user, organisation: "invalid", author: "invalid")
    assert_not filter.valid?
    assert_equal 2, filter.errors.count
    assert_includes filter.errors, "Author not found"
    assert_includes filter.errors, "Organisation not found"
  end

  test "should be invalid if from_date is incorrect" do
    filter = Admin::EditionFilter.new(Edition, @current_user, from_date: "33/33/3333")
    assert_not filter.valid?
    assert_equal 1, filter.errors.count
    assert_includes filter.errors, "The 'From date' is incorrect. It should be dd/mm/yyyy"
  end

  test "should be invalid if to_date is incorrect" do
    filter = Admin::EditionFilter.new(Edition, @current_user, to_date: "33/33/3333")
    assert_not filter.valid?
    assert_equal 1, filter.errors.count
    assert_includes filter.errors, "The 'To date' is incorrect. It should be dd/mm/yyyy"
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
    filter = Admin::EditionFilter.new(Edition, build(:user), type: "publication")
    assert_equal "Everyone’s publications", filter.page_title
  end

  test "should generate page title when filtering by document sub-type" do
    filter = Admin::EditionFilter.new(Edition, build(:user), type: "news_story")
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

  test "should generate page title for overdue reviews" do
    filter = Admin::EditionFilter.new(Edition, build(:user), review_overdue: "1")
    assert_equal "Everyone’s documents with overdue reviews", filter.page_title
  end

  test "should paginate editions" do
    3.times { create(:publication) }
    filter = Admin::EditionFilter.new(Edition, build(:user), per_page: 2)
    assert_equal 2, filter.editions.count
    assert_equal 2, filter.editions.total_pages
  end

  test "editions_for_csv should not be paginated" do
    3.times { create(:publication) }
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
