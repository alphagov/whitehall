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

  test "should list change history for published editions" do
    original_edition = create(:superseded_edition, major_change_published_at: 3.days.ago, change_note: "first version")
    document = original_edition.document
    new_edition_1 = create(:superseded_edition, document: document, major_change_published_at: 2.days.ago, change_note: "some changes")
    new_edition_2 = create(:published_edition, document: document, major_change_published_at: 1.day.ago, change_note: "more changes")

    history = document.change_history
    assert_equal 3, history.length
    assert_equal "more changes", history[0].note
    assert_equal "some changes", history[1].note
    assert_equal "first version", history[2].note
  end

  test "should omit minor changes from change history" do
    original_edition = create(:superseded_edition, major_change_published_at: 3.days.ago, change_note: nil)
    document = original_edition.document
    new_edition_1 = create(:superseded_edition, document: document, major_change_published_at: 2.days.ago, change_note: "some changes")
    new_edition_2 = create(:published_edition, document: document, major_change_published_at: 1.day.ago, change_note: "", minor_change: true)

    history = document.change_history
    assert_equal 2, history.size
    assert_equal "some changes", history[0].note
    assert_equal "First published.", history[1].note
  end

  test "should omit drafts from change history" do
    original_edition = create(:superseded_edition, major_change_published_at: 3.days.ago, change_note: "First edition")
    document = original_edition.document
    new_edition_1 = create(:draft_edition, document: document, major_change_published_at: 2.days.ago, change_note: "some changes")

    history = document.change_history
    assert_equal 1, history.size
    assert_equal "First edition", history[0].note
  end

  test 'should use "First Published" as the change note if it is not set on the first edition' do
    original_edition = create(:published_edition, major_change_published_at: 3.days.ago, change_note: "", minor_change: false)
    document = original_edition.document

    history = document.change_history
    assert_equal 1, history.length
    assert_equal "First published.", history[0].note
  end

  test "should use first published timestamp for the initial change history" do
    original_edition = create(:published_edition, first_published_at: 4.days.ago, minor_change: false)
    document = original_edition.document

    history = document.change_history
    assert_equal 1, history.length
    assert_equal 4.days.ago, history[0].public_timestamp
  end

  test "should return scheduled edition" do
    publication = create(:draft_publication, scheduled_publication: 1.day.from_now)
    publication.perform_force_schedule
    document = publication.document.reload

    assert_equal publication, document.scheduled_edition
  end
end
