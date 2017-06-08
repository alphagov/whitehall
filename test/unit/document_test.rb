require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should return documents that have published editions" do
    superseded_publication = create(:superseded_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)

    assert_equal [published_publication.document], Document.published
  end

  test "should return the published edition" do
    user = create(:departmental_editor)
    document = create(:document)
    original_publication = create(:draft_publication, document: document)
    force_publish(original_publication)
    draft_publication = original_publication.create_draft(user)
    draft_publication.change_note = "change-note"
    force_publish(draft_publication)

    superseded_publication = original_publication
    published_publication = draft_publication
    new_draft_publication = published_publication.create_draft(user)

    assert_equal published_publication, document.reload.published_edition
  end

  test "should be able to retrieve documents of a certain type at a particular slug" do
    publication = create(:draft_publication)
    assert_equal publication.document, Document.at_slug(publication.type, publication.document.slug)
  end

  test "should be able to retrieve documents of many types at a particular slug" do
    news = create(:draft_news_article)
    speech = create(:draft_speech)
    assert_equal news.document, Document.at_slug([news.type, speech.type], news.document.slug)
    assert_equal speech.document, Document.at_slug([news.type, speech.type], speech.document.slug)
  end

  test "should be published if a published edition exists" do
    published_publication = create(:published_publication)
    assert published_publication.document.published?
  end

  test "should not be published if no published edition exists" do
    draft_publication = create(:draft_publication)
    refute draft_publication.document.published?
  end

  test "should no longer be published when it's edition is unpublished" do
    published_publication = create(:published_publication)
    document = published_publication.document
    assert published_publication.document.published?

    published_publication.unpublish!

    refute published_publication.document.published?
  end

  test "should ignore deleted editions when finding latest edition" do
    document = create(:document)
    original_edition = create(:published_edition, document: document)
    deleted_edition = create(:deleted_edition, document: document)

    assert_equal original_edition, document.latest_edition
  end

  test "#pre_publication_edition returns the edition in a pre-publication state" do
    document = create(:document)
    create(:deleted_edition, document: document)
    create(:published_edition, document: document)
    draft_edition = create(:draft_edition, document: document)

    assert_equal draft_edition, document.pre_publication_edition
  end

  test "#destroy also destroys ALL editions including those marked as deleted" do
    document = create(:document)
    original_edition = create(:published_edition, document: document)
    deleted_edition = create(:deleted_edition, document: document)

    document.destroy
    refute Edition.unscoped.exists?(original_edition.id)
    refute Edition.unscoped.exists?(deleted_edition.id)
  end

  test "#destroy also destroys relations to other editions" do
    document = create(:document)
    relationship = create(:edition_relation, document: document)
    document.destroy
    assert_nil EditionRelation.find_by(id: relationship.id)
  end

  test "#destroy also destroys document sources" do
    document = create(:document)
    document_source = create(:document_source, document: document)
    document.destroy
    assert_nil DocumentSource.find_by(id: document_source.id)
  end

  test "#destroy also destroys document collection group memberships" do
    published_edition = create(:published_edition)
    document_collection = create(:published_document_collection,
      groups: [ build(:document_collection_group, documents: [published_edition.document]) ])

    published_edition.document.destroy
    assert_empty DocumentCollectionGroupMembership.where(document_id: published_edition.document.id)
  end

  test "should list a single change history when sole published edition is marked as a minor change" do
    edition = create(:published_publication, minor_change: true, change_note: nil)

    history = edition.change_history
    assert_equal 1, history.length
    assert_equal "First published.", history.first.note
  end

  test 'returns change history' do
    document = create(:document)
    history = document.change_history

    assert_equal DocumentHistory, history.class
    assert_equal document, history.document
  end

  test "should return scheduled edition" do
    publication = create(:scheduled_publication, scheduled_publication: 1.day.from_now)
    document = publication.document

    assert_equal publication, document.scheduled_edition
  end

  test "#ever_published_editions returns all editions that have ever been published or withdrawn" do
    document = create(:document)
    superseded = create(:superseded_edition, document: document)
    withdrawn = create(:edition, state: 'withdrawn', document: document)
    current = create(:published_edition, document: document)

    assert_equal [superseded, withdrawn, current], document.ever_published_editions

    current.withdraw!
    assert_equal [superseded, withdrawn, current], document.reload.ever_published_editions
  end

  test "#humanized_document_type should return document type in a user friendly format" do
    assert_equal "document collection", build(:document, document_type: "DocumentCollection").humanized_document_type
  end

  test "#similar_slug_exists? returns true if a document with a similar slug exists" do
    existing = create(:news_article, title: "Latest news")
    draft = create(:news_article, title: "Latest news")

    assert draft.document.similar_slug_exists?

    distinct_draft = create(:news_article, title: "Latest news from the crime scene")
    refute distinct_draft.document.similar_slug_exists?
  end

  test "#similar_slug_exists? scopes to documents of the same type" do
    existing = create(:news_article, title: "UK prospers")
    draft = create(:speech, title: "UK prospers")

    refute draft.document.similar_slug_exists?
  end

end
