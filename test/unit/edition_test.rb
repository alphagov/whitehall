require "test_helper"

class EditionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "returns downcased humanized class name as format name" do
    assert_equal 'case study', CaseStudy.format_name
    assert_equal 'publication', Publication.format_name
    assert_equal 'consultation', Consultation.format_name
  end

  test "delegates format name to class" do
    Edition.stubs(:format_name).returns('format name')
    assert_equal 'format name', Edition.new.format_name
  end

  test "returns capitalized format name as default display type" do
    edition = Edition.new
    edition.stubs(:format_name).returns('format name')
    assert_equal 'Format name', edition.display_type
  end

  test "adds a document before validation if none provided" do
    edition = build(:edition)
    edition.valid?
    assert_not_nil edition.document
    assert_kind_of Document, edition.document
  end

  test "uses provided document if available" do
    document = build(:document)
    edition = build(:edition, document: document)
    assert_equal document, edition.document
  end

  test ".published_as returns edition if edition is published" do
    edition = create(:published_policy)
    assert_equal edition, Policy.published_as(edition.document.to_param)
  end

  test ".published_as returns latest published edition if several editions are part of the same document" do
    edition = create(:published_policy)
    new_draft = create(:draft_policy, document: edition.document)
    assert_equal edition, Policy.published_as(edition.document.to_param)
  end

  test ".published_as returns nil if edition is not published" do
    edition = create(:submitted_edition)
    assert_nil Edition.published_as(edition.document.to_param)
  end

  test ".published_as returns nil if document is unknown" do
    assert_nil Edition.published_as('unknown')
  end

  test ".latest_edition includes first edition of any edition" do
    edition = create(:published_edition)
    assert Edition.latest_edition.include?(edition)
  end

  test ".latest_edition includes only latest edition of a edition" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))
    refute Edition.latest_edition.include?(original_edition)
    assert Edition.latest_edition.include?(new_draft)
  end

  test ".latest_edition ignores deleted editions" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    assert Edition.latest_edition.include?(original_edition)
    refute Edition.latest_edition.include?(new_draft)
  end

  test ".latest_published_edition includes only published editions" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    assert Edition.latest_published_edition.include?(original_edition)
    refute Edition.latest_published_edition.include?(new_draft)
  end

  test '.most_recent_change_note returns the most recent change note' do
    editor = create(:departmental_editor)
    edition = create(:published_edition)

    refute edition.most_recent_change_note

    version_2 = edition.create_draft(editor)
    version_2.change_note = 'My new version'
    force_publish(version_2)

    assert_equal 'My new version', version_2.most_recent_change_note

    version_3 = version_2.create_draft(editor)
    version_3.minor_change = true
    force_publish(version_3)

    assert_equal 'My new version', version_3.most_recent_change_note
  end

  test "should return a list of editions in a topic" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_policy = create(:draft_policy, topics: [topic_1])
    published_policy = create(:published_policy, topics: [topic_1])
    scheduled_policy = create(:scheduled_policy, topics: [topic_1])
    published_in_second_topic = create(:published_policy, topics: [topic_2])

    assert_equal [draft_policy, published_policy, scheduled_policy], Policy.in_topic(topic_1)
    assert_equal [published_policy], Policy.published_in_topic(topic_1)
    assert_equal [scheduled_policy], Policy.scheduled_in_topic(topic_1)
    assert_equal [published_in_second_topic], Policy.published_in_topic(topic_2)
  end

  test "should return a list of editions in an organisation" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    draft_edition = create(:draft_edition, organisations: [organisation_1])
    published_edition = create(:published_edition, organisations: [organisation_1])
    published_in_second_organisation = create(:published_edition, organisations: [organisation_2])

    assert_equal [draft_edition, published_edition], Edition.in_organisation(organisation_1)
    assert_equal [published_edition], Edition.published.in_organisation(organisation_1)
    assert_equal [published_in_second_organisation], Edition.in_organisation(organisation_2)
  end

  test "should return a list of editions in a ministerial role" do
    ministerial_role_1 = create(:ministerial_role)
    ministerial_role_2 = create(:ministerial_role)
    draft_policy = create(:draft_policy, ministerial_roles: [ministerial_role_1])
    published_policy = create(:published_policy, ministerial_roles: [ministerial_role_1])
    published_publication = create(:published_publication, ministerial_roles: [ministerial_role_1])
    published_in_second_ministerial_role = create(:published_policy, ministerial_roles: [ministerial_role_2])

    assert_equal [draft_policy, published_policy], Policy.in_ministerial_role(ministerial_role_1)
    assert_equal [published_policy], Policy.published.in_ministerial_role(ministerial_role_1)
    assert_equal [published_in_second_ministerial_role], Policy.in_ministerial_role(ministerial_role_2)
  end

  test "return editions bi-directionally related to specific edition" do
    policy = create(:policy)
    publication_1 = create(:publication, related_editions: [policy])
    publication_2 = create(:publication, related_editions: [policy])

    assert_equal [publication_1, publication_2], policy.related_editions
    assert_equal [policy], publication_1.related_policies
    assert_equal [policy], publication_2.related_policies
  end

  test "return published editions bi-directionally related to specific policy" do
    policy = create(:published_policy)
    edition_1 = create(:published_publication, related_editions: [policy])
    edition_2 = create(:published_publication, related_editions: [policy])

    assert_equal [edition_1, edition_2], policy.published_related_editions
    assert_equal [policy], edition_1.published_related_policies
    assert_equal [policy], edition_2.published_related_policies
  end

  test "#first_published_version? is true if published and published_major_version is 1" do
    policy = build(:published_policy, published_major_version: 1)
    assert policy.first_published_version?
  end

  test "#first_edition? is false if published and published_major_version is not 1" do
    policy = build(:published_policy, published_major_version: 2)
    refute policy.first_published_version?
  end

  test "#creator= builds an edition_author with the given creator for new records" do
    creator = create(:user)
    edition = build(:edition, creator: creator)
    assert_equal creator, edition.edition_authors.first.user
  end

  test "#creator= raises an exception if called for a persisted record" do
    edition = create(:edition)
    assert_raise RuntimeError do
      edition.creator = create(:user)
    end
  end

  test "last_author returns user who last edited the edition" do
    user1 = create(:departmental_editor)
    user2 = create(:user)
    edition = nil
    acting_as(user2) do
      edition = create(:draft_news_article)
    end
    assert_equal user2, edition.last_author, 'creating'

    acting_as(user1) do
      force_publish(edition)
    end
    assert_equal user1, edition.reload.last_author, 'publishing'
  end

  test ".related_to includes editions related to edition" do
    policy = create(:policy)
    publication = create(:publication, related_editions: [policy])
    assert Edition.related_to(policy).include?(publication)
  end

  test ".related_to respects chained scopes" do
    policy = create(:policy)
    publication = create(:publication, related_editions: [policy])
    assert Publication.related_to(policy).include?(publication)
    refute Policy.related_to(policy).include?(publication)
  end

  test ".related_to excludes unrelated editions" do
    publication = create(:publication)
    policy = create(:policy)
    refute Edition.related_to(policy).include?(publication)
  end

  test ".authored_by includes editions created by the given user" do
    publication = create(:publication)
    assert Edition.authored_by(publication.creator).include?(publication)
  end

  test ".authored_by includes editions edited by given user" do
    publication = create(:publication)
    writer = create(:policy_writer)
    publication.edit_as(writer, {})
    assert Edition.authored_by(writer).include?(publication)
  end

  test ".authored_by includes editions only once no matter how many edits a user has made" do
    publication = create(:publication)
    writer = create(:policy_writer)
    publication.edit_as(writer, {})
    publication.edit_as(writer, {})
    publication.edit_as(writer, {})
    assert_equal 1, Edition.authored_by(writer).all.size
  end

  test ".authored_by excludes editions creatored by another user" do
    publication = create(:publication)
    refute Edition.authored_by(create(:policy_writer)).include?(publication)
  end

  test ".authored_by respects chained scopes" do
    publication = create(:publication)
    assert Edition.authored_by(publication.creator).include?(publication)
    assert Publication.authored_by(publication.creator).include?(publication)
    refute Policy.authored_by(publication.creator).include?(publication)
  end

  test "#rejected_by uses information from the audit trail" do
    publication = create(:submitted_publication)
    user = create(:policy_writer)
    Edition::AuditTrail.whodunnit = user
    publication.reject!
    assert_equal user, publication.rejected_by
  end

  test "#rejected_by should not be confused by editorial remarks" do
    publication = create(:submitted_publication)
    user = create(:policy_writer)
    Edition::AuditTrail.whodunnit = user
    create(:editorial_remark, edition: publication)
    assert_nil publication.reload.rejected_by
  end

  test "#published_by uses information from the audit trail" do
    editor = create(:departmental_editor)
    publication = create(:submitted_publication)
    acting_as(editor) { EditionPublisher.new(publication).perform! }
    assert_equal editor, publication.published_by
  end

  test "#scheduled_by uses information from the audit trail" do
    editor = create(:departmental_editor)
    publication = create(:submitted_publication, scheduled_publication: 1.day.from_now)
    acting_as(editor) { publication.perform_force_schedule }
    assert_equal editor, publication.scheduled_by
  end

  test "#scheduled_by ignores activity on previous editions" do
    editor = create(:departmental_editor)
    robot = create(:scheduled_publishing_robot)
    publication = create(:submitted_publication, scheduled_publication: 1.day.from_now)
    acting_as(editor) { publication.perform_force_schedule }
    Timecop.freeze publication.scheduled_publication do
      acting_as(robot) { EditionPublisher.new(publication).perform! }
      acting_as(editor) do
        new_draft = publication.create_draft(editor)
        assert_equal nil, new_draft.scheduled_by
      end
    end
  end

  test ".by_major_change_published_at orders by major_change_published_at descending" do
    policy = create(:policy, major_change_published_at: 2.hours.ago)
    publication = create(:publication, major_change_published_at: 4.hours.ago)
    article = create(:news_article, major_change_published_at: 1.hour.ago)
    assert_equal [article, policy, publication], Edition.by_major_change_published_at
  end

  test "should only return the submitted editions" do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [submitted_edition], Edition.submitted
  end

  test "should return all editions excluding those that are archived or deleted" do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    rejected_edition = create(:rejected_edition)
    published_edition = create(:published_edition)
    deleted_edition = create(:draft_edition)
    deleted_edition.delete!
    archived_edition = create(:archived_edition)
    assert_same_elements [draft_edition, submitted_edition, rejected_edition, published_edition], Edition.active
  end

  test "should not return published editions in submitted" do
    edition = create(:published_edition)
    refute Edition.submitted.include?(edition)
  end

  test "should be invalid if has image but no alt text" do
    article = build(:news_article, images: [build(:image, alt_text: nil)])
    refute article.valid?
  end

  test "should still be valid if has no image and no alt text" do
    article = build(:news_article, images: [])
    assert article.valid?
  end

  test "should still be archivable if alt text validation would normally fail" do
    article = create(:published_news_article, images: [build(:image)])
    article.images.first.update_column(:alt_text, nil)
    NewsArticle.find(article.id).archive!
  end

  test "should still be deleteable if alt text validation would normally fail" do
    article = create(:submitted_news_article, images: [build(:image)])
    article.images.first.update_column(:alt_text, nil)
    NewsArticle.find(article.id).delete!
  end

  test "should be invalid without a summary" do
    refute build(:edition, summary: nil).valid?
  end

  test "generate title for a draft edition" do
    draft_edition = create(:draft_edition, title: "Holding back")
    assert_equal "Holding back (draft)", draft_edition.title_with_state
  end

  test "generate title for a submitted edition" do
    submitted_edition = create(:submitted_edition, title: "Dog Eyes")
    assert_equal "Dog Eyes (submitted)", submitted_edition.title_with_state
  end

  test "generate title for a published edition" do
    published_edition = create(:published_edition, title: "Dog Eyes")
    assert_equal "Dog Eyes (published)", published_edition.reload.title_with_state
  end

  test "should use the edition title as the basis for the document's slug" do
    edition = create(:edition, title: 'My Policy Title')
    assert_equal 'my-policy-title', edition.document.slug
  end

  test "should not include apostrophes in slug" do
    edition = create(:edition, title: "Bob's bike")
    assert_equal 'bobs-bike', edition.document.slug
  end

  test "is filterable by edition type" do
    policy = create(:policy)
    publication = create(:publication)
    news = create(:news_article)
    speech = create(:speech)
    consultation = create(:consultation)

    assert_equal [policy], Edition.by_type('Policy')
    assert_equal [publication], Edition.by_type('Publication')
    assert_equal [news], Edition.by_type('NewsArticle')
    assert_equal [speech], Edition.by_type('Speech')
    assert_equal [consultation], Edition.by_type('Consultation')
  end

  test "should return search index suitable for Rummageable" do
    policy = create(:published_policy, title: "policy-title")
    slug = policy.document.slug
    summary = policy.summary

    assert_equal "policy-title", policy.search_index["title"]
    assert_equal "/government/policies/#{slug}", policy.search_index["link"]
    assert_equal policy.body, policy.search_index["indexable_content"]
    assert_equal "policy", policy.search_index["format"]
    assert_equal summary, policy.search_index["description"]
  end

  test 'search_format_types tags the edtion as an edition' do
    edition = build(:edition)
    assert edition.search_format_types.include?('edition')
  end

  test 'concrete_descendant_search_format_types does not include Edition subclasses that themselves have subclasses' do
    concrete_formats = Edition.concrete_descendant_search_format_types

    refute concrete_formats.include? Announcement.search_format_type
    refute concrete_formats.include? Newsesque.search_format_type
    refute concrete_formats.include? Publicationesque.search_format_type
    refute concrete_formats.include? Edition.search_format_type

    assert concrete_formats.include? NewsArticle.search_format_type
    assert concrete_formats.include? WorldLocationNewsArticle.search_format_type
    assert concrete_formats.include? Speech.search_format_type
    assert concrete_formats.include? FatalityNotice.search_format_type
    assert concrete_formats.include? Publication.search_format_type
    assert concrete_formats.include? StatisticalDataSet.search_format_type
    assert concrete_formats.include? Consultation.search_format_type
    assert concrete_formats.include? DetailedGuide.search_format_type
    assert concrete_formats.include? CaseStudy.search_format_type
    assert concrete_formats.include? Policy.search_format_type
    assert concrete_formats.include? WorldwidePriority.search_format_type
  end

  test "#indexable_content should return the body without markup by default" do
    policy = create(:published_policy, body: "# header\n\nsome text")
    assert_equal "header some text", policy.indexable_content
  end

  test "should use the result of #indexable_content for the content of #search_index" do
    policy = create(:published_policy, title: "policy-title")
    policy.stubs(:indexable_content).returns("some augmented searchable content")
    assert_equal "some augmented searchable content", policy.search_index["indexable_content"]
  end

  test "should return search index data for all published editions" do
    create(:published_policy, title: "policy-title", body: "this and that",
           summary: "policy-summary")
    create(:published_publication, title: "publication-title",
           body: "stuff and things", summary: "publication-summary")
    create(:draft_publication, title: "draft-publication-title", body: "bits and bobs")

    results = Edition.search_index.to_a

    assert_equal ['policy-title', 'publication-title'], results.map {|r| r['title']}
  end

  test "should not remove edition from search index when a new draft of a published edition is deleted" do
    policy = create(:published_policy)
    new_draft_policy = policy.create_draft(create(:policy_writer))

    Searchable::Delete.expects(:later).with(policy).never

    new_draft_policy.delete!
  end

  test "should remove published edition from search index when it's unpublished" do
    policy = create(:published_policy)

    Searchable::Delete.expects(:later).with(policy)
    policy.unpublishing = build(:unpublishing)
    policy.perform_unpublish
  end

  test "swallows errors from search index when it's unpublished" do
    policy = create(:published_policy)

    Searchable::Delete.expects(:later).raises(RuntimeError, 'Problem?')
    policy.unpublishing = build(:unpublishing)
    assert_nothing_raised { policy.perform_unpublish }
  end

  test "should remove published edition from search index when it's archived" do
    policy = create(:published_policy)

    Searchable::Delete.expects(:later).with(policy)

    policy.archive!
  end

  test "swallows errors from search index when it's archived" do
    policy = create(:published_policy)
    slug = policy.document.slug

    Searchable::Delete.expects(:later).raises(RuntimeError, 'Problem?')

    assert_nothing_raised { policy.archive! }
  end

  test "#destroy should also remove the relationship to any authors" do
    edition = create(:draft_edition, creator: create(:policy_writer))
    relation = edition.edition_authors.first
    edition.destroy
    refute EditionAuthor.find_by_id(relation.id)
  end

  test "#destroy should also remove the relationship to any editorial remarks" do
    edition = create(:draft_edition, editorial_remarks: [create(:editorial_remark)])
    relation = edition.editorial_remarks.first
    edition.destroy
    refute EditorialRemark.find_by_id(relation.id)
  end

  test ".in_chronological_order returns editions in ascending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Edition.in_chronological_order.all
  end

  test ".in_reverse_chronological_order returns editions in descending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Edition.in_reverse_chronological_order.all
  end

  test ".published_before returns editions whose first_published_at is before the given date" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan], Edition.published_before("2011-01-29").all
  end

  test ".published_after returns editions whose first_published_at is after the given date" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [feb], Edition.published_after("2011-01-29").all
  end

  test "should find editions with summary containing keyword" do
    edition_with_first_keyword = create(:edition, summary: "klingons")
    edition_without_first_keyword = create(:edition, summary: "this document is about muppets")
    assert_equal [edition_with_first_keyword], Edition.with_title_or_summary_containing("klingons")
  end

  test "should find editions with summary containing regular expression characters" do
    edition_with_nasty_characters = create(:edition, summary: "summary with [stuff in brackets]")
    assert_equal [edition_with_nasty_characters], Edition.with_title_or_summary_containing("[stuff")
  end

  test "should find editions with title containing keyword" do
    edition_with_first_keyword = create(:edition, title: "klingons")
    edition_without_first_keyword = create(:edition, title: "this document is about muppets")
    assert_equal [edition_with_first_keyword], Edition.with_title_containing("klingons")
  end

  test "should find editions with slug containing keyword" do
    edition_with_first_keyword = create(:edition, title: "klingons rule")
    edition_without_first_keyword = create(:edition, title: "this document is about muppets")
    assert_equal [edition_with_first_keyword], Edition.with_title_containing("klingons-rule")
  end

  test "should find editions with title containing regular expression characters" do
    edition_with_nasty_characters = create(:edition, title: "title with [stuff in brackets]")
    assert_equal [edition_with_nasty_characters], Edition.with_title_containing("[stuff")
  end

  test "make_public_at should set first_published_at if its empty" do
    e = build(:edition, first_published_at: nil)
    e.make_public_at(2.days.ago)
    assert_equal 2.days.ago, e.first_published_at
  end

  test "make_public_at should no update first_published_at if its not empty" do
    e = build(:edition, first_published_at: 4.days.ago)
    e.make_public_at(2.days.ago)
    assert_equal 4.days.ago, e.first_published_at
  end

  test "set_public_timestamp should use first_public_at if first_published_version" do
    e = build(:edition, public_timestamp: nil)
    e.stubs(:first_public_at).returns(3.days.ago)
    e.set_public_timestamp
    assert_equal 3.days.ago, e.public_timestamp
  end

  test "set_public_timestamp should use major_change_published_at if not first_published_version" do
    e = build(:edition,
              public_timestamp: nil,
              published_major_version: 2,
              major_change_published_at: 4.days.ago)
    e.set_public_timestamp
    assert_equal 4.days.ago, e.public_timestamp
  end

  [:draft, :scheduled, :published, :archived, :submitted, :rejected].each do |state|
    test "valid_as_draft? is true for valid #{state} editions" do
      edition = build("#{state}_edition")
      assert edition.valid_as_draft?
    end
  end

  test "errors_as_draft does not have a side effect on the editions errors object" do
    edition = build("imported_publication", publication_type: PublicationType::ImportedAwaitingType)
    edition.valid?
    assert_equal({}, edition.errors.messages)
    edition.errors_as_draft
    assert_equal({}, edition.errors.messages)
  end

  test "should store title in multiple languages" do
    edition = build(:edition)
    with_locale(:en) { edition.title = 'english-title' }
    with_locale(:es) { edition.title = 'spanish-title' }
    edition.save!
    edition.reload
    assert_equal "english-title", edition.title(:en)
    assert_equal "spanish-title", edition.title(:es)
  end

  test "should only consider english titles when sorting editions alphabetically" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title-b" }
    with_locale(:es) { edition.title = "spanish-title-b" }
    edition.save!
    with_locale(:es) { create(:edition, title: "spanish-title-a") }
    with_locale(:en) { create(:edition, title: "english-title-a") }

    assert_equal %w(english-title-a english-title-b), Edition.alphabetical.map(&:title)
  end

  test "should only consider english titles for Edition.with_title_or_summary_containing" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title-b" }
    with_locale(:es) { edition.title = "spanish-title-b" }
    edition.save!
    with_locale(:es) { create(:edition, title: "spanish-title-a") }
    with_locale(:en) { create(:edition, title: "english-title-a") }

    assert_same_elements %w(english-title-a english-title-b), Edition.with_title_or_summary_containing("title").map(&:title)
  end

  test "should only consider english titles for Edition.with_title_containing" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title-b" }
    with_locale(:es) { edition.title = "spanish-title-b" }
    edition.save!
    with_locale(:es) { create(:edition, title: "spanish-title-a") }
    with_locale(:en) { create(:edition, title: "english-title-a") }

    assert_same_elements %w(english-title-a english-title-b), Edition.with_title_containing("title").map(&:title)
  end

  test "is available in multiple languages if more than one translation exist" do
    edition = build(:edition)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    assert edition.available_in_multiple_languages?
  end

  test "is not available in multiple languages if only one translation exists" do
    edition = build(:edition)
    edition.save!
    refute edition.available_in_multiple_languages?
  end

  test ".with_translations should only return editions in the given locale" do
    untranslated_edition = create(:edition, title: "english-title-a")
    translated_edition = build(:edition)
    with_locale(:en) do
      translated_edition.title = "english-title-b"
      translated_edition.summary = "english-summary-b"
      translated_edition.body = "english-body-b"
    end
    with_locale(:fr) do
      translated_edition.title = "french-title-b"
      translated_edition.summary = "french-summary-b"
      translated_edition.body = "french-body-b"
    end
    translated_edition.save!

    assert_same_elements [untranslated_edition, translated_edition], Edition.with_translations("en")
    assert_equal [translated_edition], Edition.with_translations("fr")
    assert_equal [], Edition.with_translations("ja")
  end

  test "is not translatable by default" do
    refute build(:edition).translatable?
  end

  test "returns non-english translations" do
    edition = build(:edition)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    assert_equal 1, edition.non_english_translations.length
    assert_equal :es, edition.non_english_translations.first.locale
  end

  test "has removeable translations" do
    edition = create(:edition)
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }
    with_locale(:es) { edition.update_attributes!(title: 'spanish-title', summary: 'spanish-summary', body: 'spanish-body') }

    edition.remove_translations_for(:fr)
    refute edition.translated_locales.include?(:fr)
    assert edition.translated_locales.include?(:es)
  end

  test 'without_editions_of_type allows us to exclude certain subclasses from a result set' do
    edition_1 = create(:case_study)
    edition_2 = create(:fatality_notice)

    no_case_studies = Edition.without_editions_of_type(CaseStudy)
    assert no_case_studies.include?(edition_2)
    refute no_case_studies.include?(edition_1)
  end

  test 'without_editions_of_type takes multiple classes to exclude' do
    edition_1 = create(:case_study)
    edition_2 = create(:fatality_notice)
    edition_3 = create(:detailed_guide)

    no_fatalities_or_guides = Edition.without_editions_of_type(FatalityNotice, DetailedGuide)
    assert no_fatalities_or_guides.include?(edition_1)
    refute no_fatalities_or_guides.include?(edition_2)
    refute no_fatalities_or_guides.include?(edition_3)
  end

  test 'without_editions_of_type doesn\'t exclude subclasses of the supplied classes' do
    edition_1 = create(:edition, type: 'Announcement')
    edition_2 = create(:fatality_notice)

    no_editions = Edition.without_editions_of_type(Announcement)
    assert no_editions.include?(edition_2)
    refute no_editions.include?(edition_1)
  end

  test 'relevant_to_local_government excludes editions not relevant to local government by default' do
    local_gov_policy = create(:published_policy, :with_document, relevant_to_local_government: true)
    non_local_gov_policy = create(:published_policy, :with_document, relevant_to_local_government: false)

    local_gov_publication = create(:publication, related_policy_ids: [local_gov_policy.id])
    non_local_gov_publication = create(:publication, related_policy_ids: [non_local_gov_policy.id])

    local_gov_editions = Edition.relevant_to_local_government
    assert local_gov_editions.include? local_gov_policy
    assert local_gov_editions.include? local_gov_publication

    refute local_gov_editions.include? non_local_gov_policy
    refute local_gov_editions.include? non_local_gov_publication
  end

  test 'not_relevant_to_local_government only includes editions not relevant to local government' do
    local_gov_policy = create(:published_policy, :with_document, relevant_to_local_government: true)
    non_local_gov_policy = create(:published_policy, :with_document, relevant_to_local_government: false)

    local_gov_publication = create(:publication, related_policy_ids: [local_gov_policy.id])
    non_local_gov_publication = create(:publication, related_policy_ids: [non_local_gov_policy.id])

    non_local_gov_editions = Edition.not_relevant_to_local_government
    assert non_local_gov_editions.include? non_local_gov_policy
    assert non_local_gov_editions.include? non_local_gov_publication

    refute non_local_gov_editions.include? local_gov_policy
    refute non_local_gov_editions.include? local_gov_publication
  end

  test 'deleting an edition also deletes any associated email curation queue items' do
    edition =  create(:edition)
    queue_item = EmailCurationQueueItem.create_from_edition(edition, Date.today)

    edition.delete!
    refute EmailCurationQueueItem.exists?(queue_item)
  end
end
