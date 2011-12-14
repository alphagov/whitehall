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

  test "should be invalid without an creator" do
    document = build(:document, creator: nil)
    refute document.valid?
  end

  test "should be invalid without a document identity" do
    document = build(:document)
    document.stubs(:document_identity).returns(nil)
    refute document.valid?
  end

  test "should be valid from the factory when published" do
    document = build(:published_document)
    assert document.valid?
  end

  test "should be invalid when published without published_at" do
    document = build(:published_document, published_at: nil)
    refute document.valid?
  end

  test "should be invalid if document identity has existing draft documents" do
    draft_document = create(:draft_document)
    document = build(:document, document_identity: draft_document.document_identity)
    refute document.valid?
  end

  test "should be invalid if document identity has existing submitted documents" do
    submitted_document = create(:submitted_document)
    document = build(:document, document_identity: submitted_document.document_identity)
    refute document.valid?
  end

  test "should be invalid if document identity has existing documents that need work" do
    rejected_document = create(:rejected_document)
    document = build(:document, document_identity: rejected_document.document_identity)
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

  test "should return a list of documents in a policy area" do
    policy_area_1 = create(:policy_area)
    policy_area_2 = create(:policy_area)
    draft_policy = create(:draft_policy, policy_areas: [policy_area_1])
    published_policy = create(:published_policy, policy_areas: [policy_area_1])
    published_in_second_policy_area = create(:published_policy, policy_areas: [policy_area_2])

    assert_equal [draft_policy, published_policy], Policy.in_policy_area(policy_area_1)
    assert_equal [published_policy], Policy.published.in_policy_area(policy_area_1)
    assert_equal [published_in_second_policy_area], Policy.in_policy_area(policy_area_2)
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

  test "return documents bi-directionally related to specific document" do
    document_1 = create(:publication)
    document_2 = create(:publication)
    document = create(:policy, related_documents: [document_1, document_2])

    assert_equal [document_1, document_2], document.related_documents
    assert_equal [document], document_1.related_documents
    assert_equal [document], document_2.related_documents
  end

  test "should add related documents bi-directionally" do
    document_1 = create(:publication)
    document_2 = create(:publication)
    document = create(:policy, related_documents: [])

    document.update_attributes!(related_document_ids: [document_1.id, document_2.id])

    assert_equal [document_1, document_2], document.related_documents
    assert_equal [document], document_1.related_documents
    assert_equal [document], document_2.related_documents
  end

  test "should remove related documents bi-directionally" do
    document_1 = create(:publication)
    document_2 = create(:publication)
    document = create(:policy, related_documents: [document_1, document_2])

    document.update_attributes!(related_document_ids: [])

    assert_equal [], document.related_documents
    assert_equal [], document_1.related_documents
    assert_equal [], document_2.related_documents
  end

  test "return published documents bi-directionally related to specific document" do
    document_1 = create(:published_publication)
    document_2 = create(:published_publication)
    document = create(:published_policy, related_documents: [document_1, document_2])

    assert_equal [document_1, document_2], document.published_related_documents
    assert_equal [document], document_1.published_related_documents
    assert_equal [document], document_2.published_related_documents
  end

  test "should add published related documents bi-directionally" do
    document_1 = create(:published_publication)
    document_2 = create(:published_publication)
    document = create(:published_policy, related_documents: [])

    document.update_attributes!(published_related_document_ids: [document_1.id, document_2.id])

    assert_equal [document_1, document_2], document.published_related_documents
    assert_equal [document], document_1.published_related_documents
    assert_equal [document], document_2.published_related_documents
  end

  test "should remove published related documents bi-directionally" do
    document_1 = create(:published_publication)
    document_2 = create(:published_publication)
    document = create(:published_policy, related_documents: [document_1, document_2])

    document.update_attributes!(published_related_document_ids: [])

    assert_equal [], document.published_related_documents
    assert_equal [], document_1.published_related_documents
    assert_equal [], document_2.published_related_documents
  end

  test "#creator= builds a document_creator with the given creator for new records" do
    creator = create(:user)
    document = build(:document, creator: creator)
    assert_equal creator, document.document_authors.first.user
  end

  test "#creator= raises an exception if called for a persisted record" do
    document = create(:document)
    assert_raises RuntimeError do
      document.creator = create(:user)
    end
  end

  test "#edit_as updates the document" do
    attributes = stub(:attributes)
    document = create(:policy)
    document.edit_as(create(:user), title: 'new-title')
    assert_equal 'new-title', document.reload.title
  end

  test "#edit_as records new creator if edit succeeds" do
    document = create(:policy)
    document.expects(:save).returns(true)
    user = create(:user)
    document.edit_as(user, {})
    assert_equal 2, document.document_authors.count
    assert_equal user, document.document_authors.last.user
  end

  test "#edit_as returns true if edit succeeds" do
    document = create(:policy)
    document.expects(:save).returns(true)
    assert document.edit_as(create(:user), {})
  end

  test "#edit_as does not record new creator if edit fails" do
    document = create(:policy)
    document.expects(:save).returns(false)
    user = create(:user)
    document.edit_as(user, {})
    assert_equal 1, document.document_authors.count
  end

  test "#edit_as returns false if edit fails" do
    document = create(:policy)
    document.expects(:save).returns(false)
    refute document.edit_as(create(:user), {})
  end

  test "#save_as saves the document" do
    document = create(:policy)
    document.expects(:save)
    document.save_as(create(:user))
  end

  test "#save_as records the new creator if save succeeds" do
    document = create(:policy)
    document.expects(:save).returns(true)
    user = create(:user)
    document.save_as(user)
    assert_equal 2, document.document_authors.count
    assert_equal user, document.document_authors.last.user
  end

  test "#save_as does not record new creator if save fails" do
    document = create(:policy)
    document.expects(:save).returns(true)
    user = create(:user)
    document.save_as(user)
    assert_equal 2, document.document_authors.count
    assert_equal user, document.document_authors.last.user
  end

  test "#save_as returns true if save succeeds" do
    document = create(:policy)
    document.expects(:save).returns(true)
    assert document.save_as(create(:user))
  end

  test "#edit_as returns false if save fails" do
    document = create(:policy)
    document.expects(:save).returns(false)
    refute document.save_as(create(:user))
  end

  test ".related_to includes documents related to document" do
    publication = create(:publication)
    policy = create(:policy, related_documents: [publication])
    assert Document.related_to(policy).include?(publication)
  end

  test ".related_to respects chained scopes" do
    publication = create(:publication)
    policy = create(:policy, related_documents: [publication])
    assert Publication.related_to(policy).include?(publication)
    refute Policy.related_to(policy).include?(publication)
  end

  test ".related_to excludes unrelated documents" do
    publication = create(:publication)
    policy = create(:policy)
    refute Document.related_to(policy).include?(publication)
  end

  test ".authored_by includes documents created by the given user" do
    publication = create(:publication)
    assert Document.authored_by(publication.creator).include?(publication)
  end

  test ".authored_by includes documents edited by given user" do
    publication = create(:publication)
    writer = create(:policy_writer)
    publication.edit_as(writer, {})
    assert Document.authored_by(writer).include?(publication)
  end

  test ".authored_by includes documents only once no matter how many edits a user has made" do
    publication = create(:publication)
    writer = create(:policy_writer)
    publication.edit_as(writer, {})
    publication.edit_as(writer, {})
    publication.edit_as(writer, {})
    assert_equal 1, Document.authored_by(writer).all.size
  end

  test ".authored_by excludes documents creatored by another user" do
    publication = create(:publication)
    refute Document.authored_by(create(:policy_writer)).include?(publication)
  end

  test ".authored_by respects chained scopes" do
    publication = create(:publication)
    assert Document.authored_by(publication.creator).include?(publication)
    assert Publication.authored_by(publication.creator).include?(publication)
    refute Policy.authored_by(publication.creator).include?(publication)
  end

  test ".by_published_at orders by published_at descending" do
    policy = create(:policy, published_at: 2.hours.ago)
    publication = create(:publication, published_at: 4.hours.ago)
    article = create(:news_article, published_at: 1.hour.ago)
    assert_equal [article, policy, publication], Document.by_published_at
  end

  test "should only return the submitted documents" do
    draft_document = create(:draft_document)
    submitted_document = create(:submitted_document)
    assert_equal [submitted_document], Document.submitted
  end

  test "should not be publishable when not submitted" do
    draft_document = create(:draft_document)
    refute draft_document.publishable_by?(create(:departmental_editor))
  end

  test "should not return published documents in submitted" do
    document = create(:submitted_document)
    document.publish_as(create(:departmental_editor))
    refute Document.submitted.include?(document)
  end

  test "should build a draft copy of the existing document with the supplied creator" do
    published_document = create(:published_document)
    new_creator = create(:policy_writer)
    draft_document = published_document.create_draft(new_creator)

    refute draft_document.published?
    refute draft_document.submitted?
    assert_equal new_creator, draft_document.creator
    assert_equal published_document.title, draft_document.title
    assert_equal published_document.body, draft_document.body
  end

  test "should build a draft copy with references to policy areas, organisations & ministerial roles" do
    policy_area = create(:policy_area)
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)

    published_policy = create(:published_policy, policy_areas: [policy_area], organisations: [organisation], ministerial_roles: [ministerial_role])

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal [policy_area], draft_policy.policy_areas
    assert_equal [organisation], draft_policy.organisations
    assert_equal [ministerial_role], draft_policy.ministerial_roles
  end

  test "should build a draft copy with copies of supporting pages" do
    published_policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: published_policy)
    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert draft_policy.valid?

    assert new_supporting_page = draft_policy.supporting_pages.last
    refute_equal supporting_page, new_supporting_page
    assert_equal supporting_page.title, new_supporting_page.title
    assert_equal supporting_page.body, new_supporting_page.body
  end

  test "should build a draft copy with references to related documents" do
    publication = create(:published_publication)
    policy = create(:published_policy)
    published_policy = create(:published_policy, related_documents: [publication, policy])

    draft_policy = published_policy.create_draft(create(:policy_writer))
    assert draft_policy.valid?

    assert draft_policy.related_documents.include?(policy)
    assert draft_policy.related_documents.include?(publication)
  end

  test "should build a draft copy preserving ordering with policy area" do
    policy_area = create(:policy_area)
    published_policy = create(:published_policy, policy_areas: [policy_area])
    association = policy_area.policy_area_memberships.where(policy_id: published_policy.id).first
    association.update_attributes(ordering: 31)

    draft_policy = published_policy.create_draft(create(:policy_writer))

    new_association = policy_area.policy_area_memberships.where(policy_id: draft_policy.id).first
    assert_equal 31, new_association.ordering
  end

  test "when initially created" do
    document = create(:document)
    assert document.draft?
    refute document.submitted?
    refute document.published?
  end

  test "when submitted" do
    document = create(:submitted_document)
    refute document.draft?
    assert document.submitted?
    refute document.published?
  end

  test "when published" do
    document = create(:submitted_document)
    document.publish_as(create(:departmental_editor))
    refute document.draft?
    assert document.published?
  end

  test "generate title for a draft document" do
    draft_document = create(:draft_document, title: "Holding back")
    assert_equal "Holding back (draft)", draft_document.title_with_state
  end

  test "generate title for a submitted document" do
    submitted_document = create(:submitted_document, title: "Dog Eyes")
    assert_equal "Dog Eyes (submitted)", submitted_document.title_with_state
  end

  test "generate title for a published document" do
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
    policy = create(:policy)
    publication = create(:publication)
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

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable if #{state}" do
      document = create("#{state}_document")
      assert document.editable?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be editable if #{state}" do
      document = create("#{state}_document")
      refute document.editable?
    end
  end

  test "should be rejectable by editors if submitted" do
    document = create(:submitted_document)
    assert document.rejectable_by?(build(:departmental_editor))
  end

  test "rejecting a submitted document transitions it into the rejected state" do
    submitted_document = create(:submitted_document)
    submitted_document.reject!
    assert submitted_document.rejected?
  end

  test "should not be rejectable by writers" do
    document = create(:submitted_document)
    refute document.rejectable_by?(build(:policy_writer))
  end

  [:draft, :rejected, :published, :archived, :deleted].each do |state|
    test "should not be rejectable if #{state}" do
      document = create("#{state}_document")
      refute document.rejectable_by?(build(:departmental_editor))
    end
  end

  [:draft, :published, :archived, :deleted].each do |state|
    test "should prevent a #{state} document being rejected" do
      document = create("#{state}_document")
      document.reject! rescue nil
      refute document.rejected?
    end
  end

  [:draft, :rejected].each do |state|
    test "should be submittable if #{state}" do
      document = create("#{state}_document")
      assert document.submittable?
    end
  end

  [:draft, :rejected].each do |state|
    test "submitting a #{state} document transitions it into the submitted state" do
      document = create("#{state}_document")
      document.submit!
      assert document.submitted?
    end
  end

  [:submitted, :published, :archived, :deleted].each do |state|
    test "should not be submittable if #{state}" do
      document = create("#{state}_document")
      refute document.submittable?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should prevent a #{state} document being submitted" do
      document = create("#{state}_document")
      document.submit! rescue nil
      refute document.submitted?
    end
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be deletable if #{state}" do
      document = create("#{state}_document")
      assert document.deletable?
    end
  end

  [:draft, :submitted, :rejected].each do |state|
    test "deleting a #{state} document transitions it into the deleted state" do
      document = create("#{state}_document")
      document.delete!
      assert document.deleted?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be deletable if #{state}" do
      document = create("#{state}_document")
      refute document.deletable?
    end
  end

  [:published, :archived].each do |state|
    test "should prevent a #{state} document being deleted" do
      document = create("#{state}_document")
      document.delete! rescue nil
      refute document.deleted?
    end
  end

  [:draft, :submitted].each do |state|
    test "publishing a #{state} document transitions it into the published state" do
      document = create("#{state}_document", published_at: 1.day.ago)
      document.publish!
      assert document.published?
    end
  end

  [:rejected, :archived, :deleted].each do |state|
    test "should prevent a #{state} document being published" do
      document = create("#{state}_document", published_at: 1.day.ago)
      document.publish! rescue nil
      refute document.published?
    end
  end

  test "archiving a published document transitions it into the archived state" do
    document = create(:published_document)
    document.archive!
    assert document.archived?
  end

  [:draft, :submitted, :rejected, :deleted].each do |state|
    test "should prevent a #{state} document being archived" do
      document = create("#{state}_document")
      document.archive! rescue nil
      refute document.archived?
    end
  end

  test "should not find deleted documents by default" do
    deleted_document = create(:deleted_document)
    assert_nil Document.find_by_id(deleted_document.id)
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable when #{state}" do
      document = create("#{state}_document")
      document.title = "new-title"
      document.body = "new-body"
      assert document.valid?
    end
  end

  [:published, :archived, :deleted].each do |state|
    test "should not be editable when #{state}" do
      document = create("#{state}_document")
      document.title = "new-title"
      document.body = "new-body"
      refute document.valid?
      assert_equal ["cannot be modified when document is in the #{state} state"], document.errors[:title]
      assert_equal ["cannot be modified when document is in the #{state} state"], document.errors[:body]
    end
  end

  test "should not be featurable" do
    refute Document.new.featurable?
  end

  test "should find multiple published documents with title containing search term" do
    document_1 = create(:published_document, title: "ban beards")
    document_2 = create(:published_document, title: "beards for everyone")
    assert_equal [document_1, document_2].to_set, Document.search("beard").to_set
  end

  test "should find published document with title containing search term without regard to case" do
    document = create(:published_document, title: "Ban beards")
    assert_equal [document], Document.search("ban")
  end

  test "should not find unpublished document with title containing search term" do
    create(:draft_document, title: "Ban beards")
    assert_equal [], Document.search("beard")
  end
end
