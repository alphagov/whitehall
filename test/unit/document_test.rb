require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should return documents that have published editions" do
    superseded_policy = create(:superseded_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)

    assert_equal [published_policy.document], Document.published
  end

  test "should return the published edition" do
    user = create(:departmental_editor)
    document = create(:document)
    original_policy = create(:draft_policy, document: document)
    force_publish(original_policy)
    draft_policy = original_policy.create_draft(user)
    draft_policy.change_note = "change-note"
    force_publish(draft_policy)

    superseded_policy = original_policy
    published_policy = draft_policy
    new_draft_policy = published_policy.create_draft(user)

    assert_equal published_policy, document.reload.published_edition
  end

  test "should be able to retrieve documents of a certain type at a particular slug" do
    policy = create(:draft_policy)
    assert_equal policy.document, Document.at_slug(policy.type, policy.document.slug)
  end

  test "should be able to retrieve documents of many types at a particular slug" do
    news = create(:draft_news_article)
    speech = create(:draft_speech)
    assert_equal news.document, Document.at_slug([news.type, speech.type], news.document.slug)
    assert_equal speech.document, Document.at_slug([news.type, speech.type], speech.document.slug)
  end

  test "should be published if a published edition exists" do
    published_policy = create(:published_policy)
    assert published_policy.document.published?
  end

  test "should not be published if no published edition exists" do
    draft_policy = create(:draft_policy)
    refute draft_policy.document.published?
  end

  test "should no longer be published when it's edition is unpublished" do
    published_policy = create(:published_policy)
    document = published_policy.document
    assert published_policy.document.published?

    published_policy.unpublish!

    refute published_policy.document.published?
  end

  test "should ignore deleted editions when finding latest edition" do
    document = create(:document)
    original_edition = create(:published_edition, document: document)
    deleted_edition = create(:deleted_edition, document: document)

    assert_equal original_edition, document.latest_edition
  end

  test "#destroy also destroys ALL editions including those marked as deleted" do
    document = create(:document)
    original_edition = create(:published_edition, document: document)
    deleted_edition = create(:deleted_edition, document: document)

    document.destroy
    refute Edition.unscoped.exists?(original_edition)
    refute Edition.unscoped.exists?(deleted_edition)
  end

  test "#destroy also destroys relations to other editions" do
    document = create(:document)
    relationship = create(:edition_relation, document: document)
    document.destroy
    assert_equal nil, EditionRelation.find_by_id(relationship.id)
  end

  test "#destroy also destroys document sources" do
    document = create(:document)
    document_source = create(:document_source, document: document)
    document.destroy
    assert_equal nil, DocumentSource.find_by_id(document_source.id)
  end

  test "should list a single change history when sole published edition is marked as a minor change" do
    edition = create(:published_policy, minor_change: true, change_note: nil)

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
    publication = create(:draft_publication, scheduled_publication: 1.day.from_now)
    publication.perform_force_schedule
    document = publication.document.reload

    assert_equal publication, document.scheduled_edition
  end

  test "#ever_published_editions returns all editions that have ever been published or archived" do
    document = create(:document)
    superseded = create(:superseded_edition, document: document)
    current = create(:published_edition, document: document)

    assert_equal [superseded, current], document.ever_published_editions

    current.archive!
    assert_equal [superseded, current], document.reload.ever_published_editions
  end

  test "#humanized_document_type should return document type in a user friendly format" do
    assert_equal "document collection", build(:document, document_type: "DocumentCollection").humanized_document_type
  end
end
