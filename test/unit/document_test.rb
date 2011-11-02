require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document = build(:document)
    assert document.valid?
  end

  test "should be invalid without a title" do
    document = build(:document, title: nil)
    refute document.valid?
  end

  test "should be invalid without a body" do
    document = build(:document, body: nil)
    refute document.valid?
  end

  test "should be invalid without an author" do
    document = build(:document, author: nil)
    refute document.valid?
  end

  test "should be invalid without a document identity" do
    document = build(:document)
    document.stubs(:document_identity).returns(nil)
    refute document.valid?
  end

  test "should be invalid if document identity has existing unpublished documents" do
    draft_document = create(:draft_document)
    document = build(:document, document_identity: draft_document.document_identity)
    refute document.valid?
  end

  test "should be invalid when published if document identity has existing published documents" do
    published_document = create(:published_document)
    document = build(:published_policy, document_identity: published_document.document_identity)
    refute document.valid?
  end

  test "adds a document identity before validation if none provided" do
    document = Document.new
    document.valid?
    assert_not_nil document.document_identity
    assert_kind_of DocumentIdentity, document.document_identity
  end

  test "uses provided document identity if available" do
    identity = build(:document_identity)
    document = Document.new(document_identity: identity)
    assert_equal identity, document.document_identity
  end

  test ".published_as returns document if document is published" do
    document = create(:published_document)
    assert_equal document, Document.published_as(document.document_identity.to_param)
  end

  test ".published_as returns latest published document if several documents share identity" do
    document = create(:published_document)
    new_draft = create(:draft_document, document_identity: document.document_identity)
    assert_equal document, Document.published_as(document.document_identity.to_param)
  end

  test ".published_as returns nil if document is not published" do
    document = create(:submitted_document)
    assert_nil Document.published_as(document.document_identity.to_param)
  end

  test ".published_as returns nil if identity is unknown" do
    assert_nil Document.published_as('unknown')
  end

  test "should return a list of documents in a topic" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_policy = create(:draft_policy, topics: [topic_1])
    published_policy = create(:published_policy, topics: [topic_1])
    published_in_second_topic = create(:published_policy, topics: [topic_2])

    assert_equal [draft_policy, published_policy], Policy.in_topic(topic_1)
    assert_equal [published_policy], Policy.published.in_topic(topic_1)
    assert_equal [published_in_second_topic], Policy.in_topic(topic_2)
  end

  test "should return a list of documents in an organisation" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    draft_document = create(:draft_document, organisations: [organisation_1])
    published_document = create(:published_document, organisations: [organisation_1])
    published_in_second_organisation = create(:published_document, organisations: [organisation_2])

    assert_equal [draft_document, published_document], Document.in_organisation(organisation_1)
    assert_equal [published_document], Document.published.in_organisation(organisation_1)
    assert_equal [published_in_second_organisation], Document.in_organisation(organisation_2)
  end

  test "should return a list of documents in a ministerial role" do
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

  test "should return a list of documents related to specific document" do
    published_publication_1 = create(:published_publication)
    published_publication_2 = create(:published_publication)
    published_policy = create(:published_policy, documents_related_with: [published_publication_1, published_publication_2])

    assert_equal [published_publication_1, published_publication_2], published_policy.documents_related_with.reload
  end

  test "should return a list of documents the specific document is related to" do
    published_policy = create(:published_policy)
    published_publication_1 = create(:published_publication, documents_related_with: [published_policy])
    published_publication_2 = create(:published_publication, documents_related_with: [published_policy])

    assert_equal [published_publication_1, published_publication_2], published_policy.documents_related_to.reload
  end

  test "should return a list of documents related to and from" do
    publication_1 = create(:published_publication)
    publication_2 = create(:published_publication)
    published_policy = create(:published_policy, documents_related_with: [publication_1, publication_2])
    other_policy = create(:published_policy, documents_related_with: [published_policy])

    assert_equal [other_policy], published_policy.documents_related_to
    assert_equal [publication_1, publication_2], published_policy.documents_related_with
    assert_equal [other_policy, publication_1, publication_2], published_policy.related_documents
  end

  test ".related_to includes documents_related_to document" do
    publication = create(:publication)
    policy = create(:policy, documents_related_to: [publication])
    assert Document.related_to(policy).include?(publication)
  end

  test ".related_to includes documents_related_with document" do
    publication = create(:publication)
    policy = create(:policy, documents_related_with: [publication])
    assert Document.related_to(policy).include?(publication)
  end

  test ".related_to includes documents a single time if in both documents_related_with and documents_related_to" do
    publication = create(:publication)
    policy = create(:policy, documents_related_with: [publication], documents_related_to: [publication])
    assert Document.related_to(policy).include?(publication)
    assert_equal 1, Document.related_to(policy).count
  end

  test ".related_to respects chained scopes" do
    publication = create(:publication)
    policy = create(:policy, documents_related_with: [publication], documents_related_to: [publication])
    assert Publication.related_to(policy).include?(publication)
    refute Policy.related_to(policy).include?(publication)
  end

  test ".related_to excludes unrelated documents" do
    publication = create(:publication)
    policy = create(:policy)
    refute Document.related_to(policy).include?(publication)
  end

  test "should only return unsubmitted draft documents" do
    draft_document = create(:draft_document)
    submitted_document = create(:submitted_document)
    assert_equal [draft_document], Document.unsubmitted
  end

  test "should only return the submitted documents" do
    draft_document = create(:draft_document)
    submitted_document = create(:submitted_document)
    assert_equal [submitted_document], Document.submitted
  end

  test "should be editable if a draft" do
    draft_document = create(:draft_document)
    assert draft_document.editable_by?(create(:policy_writer))
  end

  test "should not be editable if published" do
    published_document = create(:published_document)
    refute published_document.editable_by?(create(:policy_writer))
  end

  test "should not be editable if archived" do
    archived_document = create(:archived_document)
    refute archived_document.editable_by?(create(:policy_writer))
  end

  test "should be submittable if draft and not submitted" do
    draft_document = create(:draft_document)
    assert draft_document.submittable_by?(create(:policy_writer))
  end

  test "not be submittable if submitted" do
    submitted_document = create(:submitted_document)
    refute submitted_document.submittable_by?(create(:policy_writer))
  end

  test "not be submittable if published" do
    published_document = create(:published_document)
    refute published_document.submittable_by?(create(:policy_writer))
  end

  test "not be archived if archived" do
    archived_document = create(:archived_document)
    refute archived_document.submittable_by?(create(:policy_writer))
  end

  test "should not be publishable when not submitted" do
    draft_document = create(:draft_document)
    refute draft_document.publishable_by?(create(:departmental_editor))
  end

  test "should set submitted flag when submitted" do
    document = create(:draft_document)
    document.submit_as(create(:policy_writer))
    assert document.reload.submitted?
  end

  test "should not return published documents in submitted" do
    document = create(:submitted_document)
    document.publish_as(create(:departmental_editor))
    refute Document.submitted.include?(document)
  end

  test "should build a draft copy of the existing document with the supplied author" do
    published_document = create(:published_document)
    new_author = create(:policy_writer)
    draft_document = published_document.create_draft(new_author)

    refute draft_document.published?
    refute draft_document.submitted?
    assert_equal new_author, draft_document.author
    assert_equal published_document.title, draft_document.title
    assert_equal published_document.body, draft_document.body
  end

  test "should build a draft copy with references to topics, organisations & ministerial roles" do
    topic = create(:topic)
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)

    published_policy = create(:published_policy, topics: [topic], organisations: [organisation], ministerial_roles: [ministerial_role])

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal [topic], draft_policy.topics
    assert_equal [organisation], draft_policy.organisations
    assert_equal [ministerial_role], draft_policy.ministerial_roles
  end

  test "should build a draft copy with copies of supporting documents" do
    published_policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: published_policy)
    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert draft_policy.valid?

    assert new_supporting_document = draft_policy.supporting_documents.last
    refute_equal supporting_document, new_supporting_document
    assert_equal supporting_document.title, new_supporting_document.title
    assert_equal supporting_document.body, new_supporting_document.body
  end

  test "should build a draft copy with references to related documents" do
    publication = create(:published_publication)
    policy = create(:published_policy)
    published_policy = create(:published_policy, documents_related_with: [publication], documents_related_to: [policy])

    draft_policy = published_policy.create_draft(create(:policy_writer))
    assert draft_policy.valid?

    assert_equal [policy], draft_policy.documents_related_to
    assert_equal [publication], draft_policy.documents_related_with
    assert_equal [policy, publication], draft_policy.related_documents
  end

  test "when initially created" do
    document = create(:document)
    assert document.draft?
    refute document.submitted?
    refute document.published?
  end

  test "when submitted" do
    document = create(:submitted_document)
    assert document.draft?
    assert document.submitted?
    refute document.published?
  end

  test "when published" do
    document = create(:submitted_document)
    document.publish_as(create(:departmental_editor))
    refute document.draft?
    assert document.published?
  end

  test "return compound title with state included" do
    draft_document = create(:draft_document, title: "Holding back")
    assert_equal "Holding back (draft)", draft_document.title_with_state

    submitted_document = create(:submitted_document, title: "Dog Eyes")
    assert_equal "Dog Eyes (submitted)", submitted_document.title_with_state

    published_document = create(:published_document, title: "Dog Eyes")
    assert_equal "Dog Eyes (published)", published_document.reload.title_with_state
  end

  test "should use the document title as the basis for the document identity's slug" do
    document = create(:document, title: 'My Policy Title')
    assert_equal 'my-policy-title', document.document_identity.slug
  end

  test "should concatenate words containing apostrophes" do
    document = create(:document, title: "Bob's bike")
    assert_equal 'bobs-bike', document.document_identity.slug
  end

  test "is filterable by document type" do
    policy = create(:submitted_policy)
    publication = create(:published_publication)
    news = create(:news_article)
    speech = create(:speech)
    consultation = create(:consultation)

    assert_equal [policy], Document.by_type('Policy')
    assert_equal [publication], Document.by_type('Publication')
    assert_equal [news], Document.by_type('NewsArticle')
    assert_equal [speech], Document.by_type('Speech')
    assert_equal [consultation], Document.by_type('Consultation')
  end

  test "should include all speech subtypes when filtering by speech" do
    types = [
      :speech_transcript,
      :speech_draft_text,
      :speech_speaking_notes,
      :speech_written_statement,
      :speech_oral_statement
    ]

    assert_equal types.map {|t| create(t) }, Document.by_type('Speech')
  end

  test "deleting a draft document transitions it into the deleted state" do
    draft_document = create(:draft_document)
    draft_document.delete!
    assert draft_document.deleted?
  end

  test "should prevent a published document being deleted" do
    published_document = create(:published_document)
    published_document.delete! rescue nil
    refute published_document.deleted?
  end

  test "should prevent an archived document being deleted" do
    archived_document = create(:archived_document)
    archived_document.delete! rescue nil
    refute archived_document.deleted?
  end

  test "should not find deleted documents by default" do
    deleted_document = create(:deleted_document)
    assert_nil Document.find_by_id(deleted_document.id)
  end
end