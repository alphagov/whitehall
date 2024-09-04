require "test_helper"

class EditionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "returns downcased humanized class name as format name" do
    assert_equal "case study", CaseStudy.format_name
    assert_equal "publication", Publication.format_name
    assert_equal "consultation", Consultation.format_name
  end

  test "delegates format name to class" do
    Edition.stubs(:format_name).returns("format name")
    assert_equal "format name", Edition.new.format_name
  end

  test "adds a document before validation if none provided" do
    edition = build(:edition)
    edition.valid?
    assert_not_nil edition.document
    assert_kind_of Document, edition.document
  end

  test "when created, updates document edition references" do
    document = create(:document)
    document.expects(:update_edition_references).once
    create(:draft_edition, document:)
  end

  test "when state changes, updates document edition references" do
    edition = create(:draft_edition, major_change_published_at: Time.zone.now)
    edition.document.expects(:update_edition_references).times(3)
    edition.submit!
    edition.publish!
    edition.unpublish!
  end

  test "adds auth bypass id to a newly created edition" do
    edition = create(:edition)
    assert_not_nil edition.auth_bypass_id
  end

  test "generates auth bypass token for edition" do
    edition = create(:edition)
    payload = decoded_token_payload(edition.auth_bypass_token)

    assert_equal payload["sub"], edition.auth_bypass_id
    assert_equal payload["content_id"], edition.content_id
    assert_equal payload["iat"], Time.zone.now.to_i
    assert_equal payload["exp"], 1.month.from_now.to_i
  end

  test "edition has shareable preview enabled if it is in the pre-publication state and the type is not excluded" do
    draft_edition = create(:draft_case_study)
    submitted_edition = create(:submitted_case_study)
    rejected_edition = create(:rejected_case_study)
    scheduled_edition = create(:scheduled_case_study)

    assert_equal draft_edition.has_enabled_shareable_preview?, true
    assert_equal submitted_edition.has_enabled_shareable_preview?, true
    assert_equal rejected_edition.has_enabled_shareable_preview?, true
    assert_equal scheduled_edition.has_enabled_shareable_preview?, true
  end

  test "edition has shareable preview disabled if it is in the published state" do
    edition = create(:published_case_study)
    assert_equal edition.has_enabled_shareable_preview?, false
  end

  test "edition has shareable preview enabled if it has document collection type" do
    edition = create(:draft_document_collection)
    assert_equal edition.has_enabled_shareable_preview?, true
  end

  test "uses provided document if available" do
    document = build(:document)
    edition = build(:edition, document:)
    assert_equal document, edition.document
  end

  test ".published_as returns edition if edition is published" do
    edition = create(:published_publication)
    assert_equal edition, Publication.published_as(edition.document.to_param)
  end

  test ".published_as returns latest published edition if several editions are part of the same document" do
    edition = create(:published_publication)
    _new_draft = create(:draft_publication, document: edition.document)
    assert_equal edition, Publication.published_as(edition.document.to_param)
  end

  test ".published_as returns nil if edition is not published" do
    edition = create(:submitted_edition)
    assert_nil Edition.published_as(edition.document.to_param)
  end

  test ".published_as returns nil if document is unknown" do
    assert_nil Edition.published_as("unknown")
  end

  test ".latest_edition includes first edition of any edition" do
    edition = create(:published_edition)
    assert Edition.latest_edition.include?(edition)
  end

  test ".latest_edition includes only latest edition of a document" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:writer))
    assert_not Edition.latest_edition.include?(original_edition)
    assert Edition.latest_edition.include?(new_draft)
  end

  test ".latest_edition ignores deleted editions" do
    document = create(:document)
    original_edition = create(:published_edition, document:)
    deleted_edition = create(:deleted_edition, document:)

    assert Edition.latest_edition.include?(original_edition)
    assert_not Edition.latest_edition.include?(deleted_edition)
  end

  test ".live_edition includes only currently live edition of a document" do
    document = create(:document)
    create(:superseded_edition, document:)
    published = create(:published_edition, document:)
    create(:draft_edition, document:)

    assert [published], Edition.live_edition
  end

  test ".most_recent_change_note returns the most recent change note" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)

    assert_not edition.most_recent_change_note,
               "Expected nil, found #{edition.most_recent_change_note}"

    version2 = edition.create_draft(editor)
    version2.change_note = "My new version"
    force_publish(version2)

    assert_equal "My new version", version2.most_recent_change_note

    version3 = version2.create_draft(editor)
    version3.minor_change = true
    force_publish(version3)

    assert_equal "My new version", version3.most_recent_change_note
  end

  test "can find editions due for publication" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    _already_published = create(:edition, :published, scheduled_publication: 1.day.from_now)
    Timecop.freeze 1.day.from_now do
      assert_equal [due_in_one_day], Edition.due_for_publication
    end
    Timecop.freeze 2.days.from_now do
      assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication
    end
  end

  test "can find editions due for publication within a certain time span" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    assert_equal [due_in_one_day], Edition.due_for_publication(1.day)
    assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication(2.days)
  end

  test ".scheduled_for_publication_as returns edition if edition is scheduled" do
    edition = build(:scheduled_publication, scheduled_publication: 1.day.from_now)
    edition.previously_published = false
    edition.save!
    assert_equal edition, Publication.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if edition is not scheduled" do
    edition = create(:draft_publication, scheduled_publication: 1.day.from_now)
    assert_nil Edition.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if document is unknown" do
    assert_nil Edition.scheduled_for_publication_as("unknown")
  end

  test "should return a list of editions in an organisation" do
    organisation1 = create(:organisation)
    organisation2 = create(:organisation)
    draft_edition = create(:draft_publication, organisations: [organisation1])
    published_edition = create(:published_publication, organisations: [organisation1])
    published_in_second_organisation = create(:published_publication, organisations: [organisation2])

    assert_equal [draft_edition, published_edition], Publication.in_organisation(organisation1)
    assert_equal [published_edition], Publication.published.in_organisation(organisation1)
    assert_equal [published_in_second_organisation], Publication.in_organisation(organisation2)
  end

  test "#first_published_version? is true if published and published_major_version is 1" do
    edition = build(:published_edition, published_major_version: 1)
    assert edition.first_published_version?
  end

  test "#first_published_major_version? is true if published_major_version is 1 and published minor version is 0" do
    edition = build(:published_edition, published_major_version: 1, published_minor_version: 0)
    assert edition.first_published_major_version?
  end

  test "#first_edition? is false if published and published_major_version is not 1" do
    edition = build(:published_edition, published_major_version: 2)
    assert_not edition.first_published_version?
  end

  test "#creator= builds an edition_author with the given creator for new records" do
    creator = create(:user)
    edition = build(:edition, creator:)
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
    assert_equal user2, edition.last_author, "creating"

    acting_as(user1) do
      force_publish(edition)
    end
    assert_equal user1, edition.reload.last_author, "publishing"
  end

  test ".authored_by includes editions created by the given user" do
    publication = create(:publication)
    assert Edition.authored_by(publication.creator).include?(publication)
  end

  test ".authored_by includes editions edited by given user" do
    publication = create(:publication)
    writer = create(:writer)
    publication.save_as(writer)
    assert Edition.authored_by(writer).include?(publication)
  end

  test ".authored_by includes editions only once no matter how many edits a user has made" do
    publication = create(:publication)
    writer = create(:writer)
    publication.save_as(writer)
    publication.save_as(writer)
    publication.save_as(writer)
    assert_equal 1, Edition.authored_by(writer).size
  end

  test ".authored_by excludes editions creatored by another user" do
    publication = create(:publication)
    assert_not Edition.authored_by(create(:writer)).include?(publication)
  end

  test ".authored_by respects chained scopes" do
    publication = create(:publication)
    assert Edition.authored_by(publication.creator).include?(publication)
    assert Publication.authored_by(publication.creator).include?(publication)
    assert_not NewsArticle.authored_by(publication.creator).include?(publication)
  end

  test "#rejected_by uses information from the audit trail and returns the user who first rejected the edition" do
    publication = create(:submitted_publication)
    user = create(:writer)
    user2 = create(:writer)
    AuditTrail.acting_as(user) { publication.reject! }
    AuditTrail.acting_as(user2) { publication.update!(title: "new title") }
    assert_equal user, publication.rejected_by
  end

  test "#rejected_by should not be confused by editorial remarks" do
    publication = create(:submitted_publication)
    user = create(:writer)
    AuditTrail.acting_as(user) { create(:editorial_remark, edition: publication) }
    assert_nil publication.reload.rejected_by
  end

  test "#submitted_by uses information from the audit trail" do
    publication = create(:draft_publication)
    user = create(:writer)
    AuditTrail.acting_as(user) { publication.submit! }
    assert_equal user, publication.submitted_by
  end

  test "#submitted_by gets original submitter even if updates are made while in submitted state" do
    submitter = create(:writer)
    reviewer = create(:writer)
    publication = create(:submitted_publication, submitter:)
    AuditTrail.acting_as(reviewer) { publication.update!(body: "updated body") }
    assert_equal submitter, publication.submitted_by
    assert_equal reviewer, publication.versions.last.user
  end

  test "#published_by uses information from the audit trail" do
    editor = create(:departmental_editor)
    publication = create(:submitted_publication)
    acting_as(editor) do
      Whitehall.edition_services.publisher(publication).perform!
    end
    assert_equal editor, publication.published_by
  end

  test "#scheduled_by uses information from the audit trail" do
    editor = create(:departmental_editor)
    publication = create(:submitted_publication, scheduled_publication: 1.day.from_now)
    acting_as(editor) { Whitehall.edition_services.force_scheduler(publication).perform! }
    assert_equal editor, publication.scheduled_by
  end

  test "#scheduled_by ignores activity on previous editions" do
    editor = create(:departmental_editor)
    robot = create(:scheduled_publishing_robot)
    publication = create(:submitted_publication, scheduled_publication: 1.day.from_now)

    acting_as(editor) { Whitehall.edition_services.force_scheduler(publication).perform! }
    Timecop.freeze publication.scheduled_publication do
      acting_as(robot) { Whitehall.edition_services.scheduled_publisher(publication).perform! }
      acting_as(editor) do
        new_draft = publication.create_draft(editor)
        assert_nil new_draft.scheduled_by
      end
    end
  end

  test ".by_major_change_published_at orders by major_change_published_at descending" do
    edition = create(:edition, major_change_published_at: 2.hours.ago)
    publication = create(:publication, major_change_published_at: 4.hours.ago)
    article = create(:news_article, major_change_published_at: 1.hour.ago)
    assert_equal [article, edition, publication], Edition.by_major_change_published_at
  end

  test "should only return the submitted editions" do
    _draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    assert_equal [submitted_edition], Edition.submitted
  end

  test "should return all editions excluding those that are superseded or deleted" do
    draft_edition = create(:draft_edition)
    submitted_edition = create(:submitted_edition)
    rejected_edition = create(:rejected_edition)
    published_edition = create(:published_edition)
    _deleted_edition = create(:deleted_edition)
    _superseded_edition = create(:superseded_edition)
    assert_same_elements [draft_edition, submitted_edition, rejected_edition, published_edition], Edition.active
  end

  test "should not return published editions in submitted" do
    edition = create(:published_edition)
    assert_not Edition.submitted.include?(edition)
  end

  test "should be valid if it has image but no alt text" do
    article = build(:news_article, images: [build(:image, alt_text: nil)])
    assert article.valid?
  end

  test "should still be valid if has no image and no alt text" do
    article = build(:news_article, images: [])
    assert article.valid?
  end

  test "should still be supersedeable if alt text validation would normally fail" do
    article = create(:published_news_article, images: [build(:image)])
    article.images.first.update_column(:alt_text, nil)
    NewsArticle.find(article.id).supersede!
  end

  test "should be invalid without a summary" do
    assert_not build(:edition, summary: nil).valid?
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
    edition = create(:edition, title: "My Publication Title")
    assert_equal "my-publication-title", edition.document.slug
  end

  test "should not include apostrophes in slug" do
    edition = create(:edition, title: "Bob's bike")
    assert_equal "bobs-bike", edition.document.slug
  end

  test "should not include ellipsis in the slug" do
    edition = create(:edition, title: "Something… going on")
    assert_equal "something-going-on", edition.document.slug
  end

  test "is filterable by edition type" do
    publication = create(:publication)
    news = create(:news_article)
    speech = create(:speech)
    consultation = create(:consultation)

    assert_equal [publication], Edition.by_type("Publication")
    assert_equal [news], Edition.by_type("NewsArticle")
    assert_equal [speech], Edition.by_type("Speech")
    assert_equal [consultation], Edition.by_type("Consultation")
  end

  test "should return search index suitable for Searchable" do
    government = create(:current_government)
    publication = create(:published_policy_paper, title: "publication-title", political: true, first_published_at: government.start_date)
    slug = publication.document.slug
    summary = publication.summary

    assert_equal "publication-title", publication.search_index["title"]
    assert_equal "/government/publications/#{slug}", publication.search_index["link"]
    assert_equal publication.body, publication.search_index["indexable_content"]
    assert_equal "publication", publication.search_index["format"]
    assert_equal "policy-paper", publication.search_index["detailed_format"]
    assert_equal summary, publication.search_index["description"]
    assert_equal publication.political?, publication.search_index["is_political"]
    assert_equal publication.historic?, publication.search_index["is_historic"]
    assert_equal government.name, publication.search_index["government_name"]
    assert_equal "policy_paper", publication.search_index["content_store_document_type"]
    assert_equal [], publication.search_index["people"]
    assert_equal [], publication.search_index["roles"]
  end

  test "search_api topical_events include topical_events" do
    government = create(:current_government)
    publication = create(:published_policy_paper, :with_topical_events, title: "publication-title", political: true, first_published_at: government.start_date)

    expected = publication.topical_events.map(&:name)
    assert_equal expected.sort, publication.search_index["topical_events"].sort
    assert_not publication.search_index.include?("topics")
  end

  test "search_format_types tags the edtion as an edition" do
    edition = build(:searchable_edition)
    assert edition.search_format_types.include?("edition")
  end

  test "concrete_descendant_search_format_types does not include Edition subclasses that themselves have subclasses" do
    concrete_formats = Edition.concrete_descendant_search_format_types

    assert_not concrete_formats.include? Announcement.search_format_type
    assert_not concrete_formats.include? Publicationesque.search_format_type
    assert_not concrete_formats.include? Edition.search_format_type

    assert concrete_formats.include? NewsArticle.search_format_type
    assert concrete_formats.include? Speech.search_format_type
    assert concrete_formats.include? FatalityNotice.search_format_type
    assert concrete_formats.include? Publication.search_format_type
    assert concrete_formats.include? StatisticalDataSet.search_format_type
    assert concrete_formats.include? Consultation.search_format_type
    assert concrete_formats.include? DetailedGuide.search_format_type
    assert concrete_formats.include? CaseStudy.search_format_type
  end

  test "#indexable_content should return the body without markup by default" do
    publication = create(:published_publication, body: "# header\n\nsome text")
    assert_equal "header some text", publication.indexable_content
  end

  test "should use the result of #indexable_content for the content of #search_index" do
    publication = create(:published_publication, title: "publication-title")
    publication.stubs(:indexable_content).returns("some augmented searchable content")
    assert_equal "some augmented searchable content", publication.search_index["indexable_content"]
  end

  test "should return search index data for all published editions" do
    create(
      :published_news_article,
      title: "news_article-title",
      body: "this and that",
      summary: "news_article-summary",
    )
    create(
      :published_publication,
      title: "publication-title",
      body: "stuff and things",
      summary: "publication-summary",
    )
    create(:draft_publication, title: "draft-publication-title", body: "bits and bobs")

    result_titles = [
      NewsArticle.search_index.to_a,
      Publication.search_index.to_a,
    ].flatten.map { |r| r["title"] }

    assert_equal %w[news_article-title publication-title], result_titles
  end

  test "#destroy should also remove the relationship to any authors" do
    edition = create(:draft_edition, creator: create(:writer))
    relation = edition.edition_authors.first
    edition.destroy!
    assert_not EditionAuthor.find_by(id: relation.id)
  end

  test "#destroy should also remove the relationship to any editorial remarks" do
    edition = create(:draft_edition, editorial_remarks: [create(:editorial_remark)])
    relation = edition.editorial_remarks.first
    edition.destroy!
    assert_not EditorialRemark.find_by(id: relation.id)
  end

  test ".in_chronological_order returns editions in ascending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Edition.in_chronological_order.to_a
  end

  test ".in_reverse_chronological_order returns editions in descending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Edition.in_reverse_chronological_order.to_a
  end

  test "re-editioned documents that share a timestamp are returned in document ID order and do not jump the queue when sorted in_chronological_order" do
    jan        = create(:edition, :published, first_published_at: Date.parse("2011-01-01"))
    feb        = create(:edition, :published, first_published_at: Date.parse("2011-02-01"))
    second_feb = create(:edition, :published, first_published_at: Date.parse("2011-02-01"))

    assert_equal [jan, feb, second_feb].collect(&:id), Edition.published.in_chronological_order.collect(&:id)

    re_editioned_feb = feb.create_draft(create(:writer))
    re_editioned_feb.minor_change = true
    force_publish(re_editioned_feb)

    assert_equal [jan, re_editioned_feb, second_feb].collect(&:id), Edition.published.in_chronological_order.collect(&:id)
  end

  test "re-editioned documents that share a timestamp are returned in document ID order and do not jump the queue when sorted in_reverse_chronological_order" do
    jan        = create(:edition, :published, first_published_at: Date.parse("2011-01-01"))
    feb        = create(:edition, :published, first_published_at: Date.parse("2011-02-01"))
    second_feb = create(:edition, :published, first_published_at: Date.parse("2011-02-01"))

    assert_equal [second_feb, feb, jan].collect(&:id), Edition.published.in_reverse_chronological_order.collect(&:id)

    re_editioned_feb = feb.create_draft(create(:writer))
    re_editioned_feb.minor_change = true
    force_publish(re_editioned_feb)

    assert_equal [second_feb, re_editioned_feb, jan].collect(&:id), Edition.published.in_reverse_chronological_order.collect(&:id)
  end

  test ".in_reverse_chronological_order works for editions that share the same document and timestamp" do
    edition1 = create(:superseded_edition)
    document = edition1.document
    edition2 = create(:superseded_edition, document:)
    edition3 = create(:superseded_edition, document:)

    assert_equal [edition3, edition2, edition1].collect(&:id), Edition.in_reverse_chronological_order.collect(&:id)
  end

  test ".published_before returns editions whose first_published_at is before the given date" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    _feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan], Edition.published_before("2011-01-29").load
  end

  test ".published_after returns editions whose first_published_at is after the given date" do
    _jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [feb], Edition.published_after("2011-01-29").load
  end

  test "should find editions with summary containing keyword" do
    edition_with_first_keyword = create(:edition, summary: "klingons")
    _edition_without_first_keyword = create(:edition, summary: "this document is about muppets")
    assert_equal [edition_with_first_keyword], Edition.with_title_or_summary_containing("klingons")
  end

  test "should find editions with summary containing regular expression characters" do
    edition_with_nasty_characters = create(:edition, summary: "summary with [stuff in brackets]")
    assert_equal [edition_with_nasty_characters], Edition.with_title_or_summary_containing("[stuff")
  end

  test "should find editions with title containing keyword" do
    edition_with_first_keyword = create(:edition, title: "klingons")
    _edition_without_first_keyword = create(:edition, title: "this document is about muppets")
    assert_equal [edition_with_first_keyword], Edition.with_title_containing("klingons")
  end

  test "should find editions with slug containing keyword" do
    edition_with_first_keyword = create(:edition, title: "klingons rule")
    _edition_without_first_keyword = create(:edition, title: "this document is about muppets")
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
    e = build(
      :edition,
      public_timestamp: nil,
      published_major_version: 2,
      major_change_published_at: 4.days.ago,
    )
    e.set_public_timestamp
    assert_equal 4.days.ago, e.public_timestamp
  end

  test "should store title in multiple languages" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title" }
    with_locale(:es) { edition.title = "spanish-title" }
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

    assert_equal %w[english-title-a english-title-b], Edition.alphabetical.map(&:title)
  end

  test "should only consider english titles for Edition.with_title_or_summary_containing" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title-b" }
    with_locale(:es) { edition.title = "spanish-title-b" }
    edition.save!
    with_locale(:es) { create(:edition, title: "spanish-title-a") }
    with_locale(:en) { create(:edition, title: "english-title-a") }

    assert_same_elements %w[english-title-a english-title-b], Edition.with_title_or_summary_containing("title").map(&:title)
  end

  test "should only consider english titles for Edition.with_title_containing" do
    edition = build(:edition)
    with_locale(:en) { edition.title = "english-title-b" }
    with_locale(:es) { edition.title = "spanish-title-b" }
    edition.save!
    with_locale(:es) { create(:edition, title: "spanish-title-a") }
    with_locale(:en) { create(:edition, title: "english-title-a") }

    assert_same_elements %w[english-title-a english-title-b], Edition.with_title_containing("title").map(&:title)
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
    assert_not edition.available_in_multiple_languages?
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
    assert_not build(:edition).translatable?
  end

  test "returns non-english translations" do
    edition = build(:edition)
    with_locale(:es) { edition.title = "spanish-title" }
    edition.save!
    assert_equal 1, edition.non_english_translations.length
    assert_equal :es, edition.non_english_translations.first.locale
  end

  test "has removeable translations" do
    stub_any_publishing_api_call

    edition = create(:edition)
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", body: "french-body") }
    with_locale(:es) { edition.update!(title: "spanish-title", summary: "spanish-summary", body: "spanish-body") }

    edition.remove_translations_for(:fr)
    assert_not edition.translated_locales.include?(:fr)
    assert edition.translated_locales.include?(:es)
  end

  test "without_editions_of_type allows us to exclude certain subclasses from a result set" do
    edition1 = create(:case_study)
    edition2 = create(:fatality_notice)

    no_case_studies = Edition.without_editions_of_type(CaseStudy)
    assert no_case_studies.include?(edition2)
    assert_not no_case_studies.include?(edition1)
  end

  test "without_editions_of_type takes multiple classes to exclude" do
    edition1 = create(:case_study)
    edition2 = create(:fatality_notice)
    edition3 = create(:detailed_guide)

    no_fatalities_or_guides = Edition.without_editions_of_type(FatalityNotice, DetailedGuide)
    assert no_fatalities_or_guides.include?(edition1)
    assert_not no_fatalities_or_guides.include?(edition2)
    assert_not no_fatalities_or_guides.include?(edition3)
  end

  test "without_editions_of_type doesn't exclude subclasses of the supplied classes" do
    edition1 = create(:edition, type: "Announcement")
    edition2 = create(:fatality_notice)

    no_editions = Edition.without_editions_of_type(Announcement)
    assert no_editions.include?(edition2)
    assert_not no_editions.include?(edition1)
  end

  should_not_accept_footnotes_in :body

  test "previously_published returns true for edition with first_published_at timestamp" do
    edition = create(:edition)
    assert_not edition.previously_published

    edition.first_published_at = Time.zone.now
    assert edition.previously_published
  end

  test "first_published_at required when previously_published" do
    edition = build(:edition, previously_published: true)
    assert_not edition.valid?
    assert_equal "Enter a first published date", edition.errors.full_messages.first

    edition.first_published_at = Time.zone.now
    assert edition.valid?
  end

  test "first_published_at cannot be set to a future date" do
    edition = build(:edition, first_published_at: 10.years.from_now)

    assert_not edition.valid?
    assert_equal "First published date must be between 1/1/1900 and the present", edition.errors.full_messages.first
  end

  test "#government returns the associated government when the edition has a specific government_id" do
    create(:current_government)
    previous_government = create(:previous_government)
    edition = create(:edition, first_published_at: Time.zone.now, government_id: previous_government.id)
    assert_equal previous_government, edition.government
  end

  test "#government returns the current government for a newly published edition" do
    government = create(:current_government)
    edition = create(:edition, first_published_at: Time.zone.now)
    assert_equal government, edition.government
  end

  test "#government returns the historic government for a previously published edition" do
    previous_government = create(:previous_government)
    create(:current_government)
    edition = create(:edition, first_published_at: 4.years.ago)
    assert_equal previous_government, edition.government
  end

  test "#government returns nil for an edition without a first_published_at" do
    edition = create(:edition, first_published_at: nil)
    assert_nil edition.government
  end

  test "#historic? is true when political and from a previous government" do
    create(:current_government)
    previous_government = create(:previous_government)

    edition = create(:edition, political: true, first_published_at: previous_government.start_date)
    assert edition.historic?
  end

  test "#historic? is false for when not political or from the current government" do
    current_government = create(:current_government)

    previous_government = create(:previous_government)

    edition = create(:edition, political: false, first_published_at: previous_government.start_date)
    assert_not edition.historic?

    edition = create(:edition, political: false, first_published_at: current_government.start_date)
    assert_not edition.historic?

    edition = create(:edition, political: true, first_published_at: current_government.start_date)
    assert_not edition.historic?
  end

  test "#historic? is false when the document has no government" do
    edition = create(:edition, political: true, first_published_at: nil)
    assert_not edition.historic?

    edition = create(:edition, political: false, first_published_at: nil)
    assert_not edition.historic?
  end

  test "#has_been_tagged? is false when request from publishing-api has no taxons" do
    edition = create(:edition)

    stub_publishing_api_has_links(
      {
        "content_id" => edition.content_id,
        "links" => {
          "organisations" => %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
        },
        "version" => 1,
      },
    )

    assert_not edition.has_been_tagged?
  end

  test "#has_been_tagged? is true when request from publishing-api has taxons" do
    edition = create(:edition)

    stub_publishing_api_has_links(
      {
        "content_id" => edition.content_id,
        "links" => {
          "organisations" => %w[569a9ee5-c195-4b7f-b9dc-edc17a09113f],
          "taxons" => %w[7754ae52-34aa-499e-a6dd-88f04633b8ab],
        },
        "version" => 1,
      },
    )

    assert edition.has_been_tagged?
  end

  test "#attachables returns empty array" do
    non_attachable_edition = build(:announcement)
    assert_not non_attachable_edition.allows_attachments?
    assert_equal [], non_attachable_edition.attachables
  end

  test "republishes a linked Topical Event when the edition is changed" do
    edition = create(:edition, :draft)
    topical_event = create(:topical_event, :active)
    create(:topical_event_featuring, topical_event:, edition:)

    Whitehall::PublishingApi.expects(:republish_async).with(topical_event).once
    edition.update!(title: "some updated title")
  end

  test "display type translates correctly for languages which do and don't use singular nouns" do
    locales_and_expected_translations = {
      de: "document.type.generic_edition.one",
      zh: "document.type.generic_edition.other",
    }
    locales_and_expected_translations.each do |locale, expected_translation_path|
      with_locale(locale) do
        speech = create(:edition)
        assert_equal I18n.t(expected_translation_path), speech.display_type
      end
    end
  end

  test "#versioning_completed? returns true if change note is not required" do
    edition = build(:edition, change_note: nil, minor_change: false)
    edition.stubs(:change_note_required?).returns(false)

    assert edition.versioning_completed?
  end

  test "#versioning_completed? returns true when a change note is present" do
    edition = build(:edition, change_note: "This is a change.", minor_change: false)
    edition.stubs(:change_note_required?).returns(true)

    assert edition.versioning_completed?
  end

  test "#versioning_completed? returns true when edition is minor version" do
    edition = build(:edition, minor_change: true)
    edition.stubs(:change_note_required?).returns(true)

    assert edition.versioning_completed?
  end

  test "#versioning_completed? returns false when change note is blank and not a minor version" do
    edition = build(:edition, change_note: nil, minor_change: false)
    edition.stubs(:change_note_required?).returns(true)

    assert_not edition.versioning_completed?
  end

  test "#force_scheduled? returns true when state is scheduled and #force_published? returns true" do
    edition = build(:edition, :force_scheduled)
    assert edition.force_scheduled?
  end

  test "#force_scheduled? returns false for a force published document" do
    edition = build(:edition, :force_published)
    assert_not edition.force_scheduled?
  end

  test "#force_scheduled? returns false for a scheduled document" do
    edition = build(:edition, :scheduled)
    assert_not edition.force_scheduled?
  end

  test "#can_have_custom_lead_image? returns true if CustomLeadImage module is included" do
    edition = build(:case_study)
    assert edition.can_have_custom_lead_image?
  end

  test "#can_have_custom_lead_image? returns true if CustomLeadImage module is not included" do
    edition = build(:edition)
    assert_not edition.can_have_custom_lead_image?
  end

  test "images_have_unique_filenames? returns true if image filenames are unique" do
    image1 = build(:image)
    image2 = build(:image, image_data: build(:image_data, file: upload_fixture("big-cheese.960x640.jpg")))
    edition = build(:draft_news_article, images: [image1, image2])

    assert_equal true, edition.images_have_unique_filenames?
  end

  test "images_have_unique_filenames? returns false if some images have duplicate filenames" do
    image1 = build(:image)
    image2 = build(:image)
    edition = build(:draft_news_article, images: [image1, image2])

    assert_equal false, edition.images_have_unique_filenames?
  end

  def decoded_token_payload(token)
    payload, _header = JWT.decode(
      token,
      Rails.application.credentials.jwt_auth_secret,
      true,
      { algorithm: "HS256" },
    )
    payload
  end
end
