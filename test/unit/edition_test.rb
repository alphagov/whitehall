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

  test ".latest_published_edition" do
    original_edition = create(:published_edition)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    assert Edition.latest_published_edition.include?(original_edition)
    refute Edition.latest_published_edition.include?(new_draft)
  end

  test "should return a list of editions in a topic" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    draft_policy = create(:draft_policy, topics: [topic_1])
    published_policy = create(:published_policy, topics: [topic_1])
    published_in_second_topic = create(:published_policy, topics: [topic_2])

    assert_equal [draft_policy, published_policy], Policy.in_topic(topic_1)
    assert_equal [published_policy], Policy.published.in_topic(topic_1)
    assert_equal [published_in_second_topic], Policy.in_topic(topic_2)
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
    publication_1 = create(:publication, related_policies: [policy])
    publication_2 = create(:publication, related_policies: [policy])

    assert_equal [publication_1, publication_2], policy.related_editions
    assert_equal [policy], publication_1.related_policies
    assert_equal [policy], publication_2.related_policies
  end

  test "return published editions bi-directionally related to specific policy" do
    policy = create(:published_policy)
    edition_1 = create(:published_publication, related_policies: [policy])
    edition_2 = create(:published_publication, related_policies: [policy])

    assert_equal [edition_1, edition_2], policy.published_related_editions
    assert_equal [policy], edition_1.published_related_policies
    assert_equal [policy], edition_2.published_related_policies
  end

  test "#first_edition? is true if published and first_published_at equals published_at" do
    policy = create(:published_policy)
    assert policy.first_edition?
  end

  test "#first_edition? is false if published and first_published_at doesn't equal published_at" do
    policy = create(:published_policy, first_published_at: 1.minute.ago)
    refute policy.first_edition?
  end

  test "#creator= builds an edition_author with the given creator for new records" do
    creator = create(:user)
    edition = build(:edition, creator: creator)
    assert_equal creator, edition.edition_authors.first.user
  end

  test "#creator= raises an exception if called for a persisted record" do
    edition = create(:edition)
    assert_raises RuntimeError do
      edition.creator = create(:user)
    end
  end

  test ".related_to includes editions related to edition" do
    policy = create(:policy)
    publication = create(:publication, related_policies: [policy])
    assert Edition.related_to(policy).include?(publication)
  end

  test ".related_to respects chained scopes" do
    policy = create(:policy)
    publication = create(:publication, related_policies: [policy])
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
    PaperTrail.whodunnit = user
    publication.reject!
    assert_equal user, publication.rejected_by
  end

  test "#rejected_by should not be confused by editorial remarks" do
    publication = create(:submitted_publication)
    user = create(:policy_writer)
    PaperTrail.whodunnit = user
    create(:editorial_remark, edition: publication)
    assert_nil publication.reload.rejected_by
  end

  test "#published_by uses information from the audit trail" do
    editor = create(:departmental_editor)
    publication = create(:submitted_publication)
    acting_as(editor) { publication.publish_as(editor, force: true) }
    assert_equal editor, publication.published_by
  end

  test ".by_published_at orders by published_at descending" do
    policy = create(:policy, published_at: 2.hours.ago)
    publication = create(:publication, published_at: 4.hours.ago)
    article = create(:news_article, published_at: 1.hour.ago)
    assert_equal [article, policy, publication], Edition.by_published_at
  end

  test ".latest_published_at returns the most recent published_at from published editions" do
    policy = create(:published_policy, published_at: 2.hours.ago)
    publication = create(:published_publication, published_at: 4.hours.ago)
    assert_equal policy.published_at, Edition.latest_published_at
  end

  test ".latest_published_at ignores unpublished editions" do
    policy = create(:draft_policy, published_at: 2.hours.ago)
    publication = create(:published_publication, published_at: 4.hours.ago)
    assert_equal publication.published_at, Edition.latest_published_at
  end

  test ".latest_published_at returns nil if no published editions exist" do
    assert_nil Edition.latest_published_at
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
    deleted_edition = create(:deleted_edition)
    archived_edition = create(:archived_edition)
    assert_same_elements [draft_edition, submitted_edition, rejected_edition, published_edition], Edition.active
  end

  test "should not be publishable when not submitted" do
    draft_edition = create(:draft_edition)
    refute draft_edition.publishable_by?(create(:departmental_editor))
  end

  test "should not return published editions in submitted" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
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
    article.images.first.update_attribute(:alt_text, nil)
    NewsArticle.find(article.id).archive!
  end

  test "should still be deleteable if alt text validation would normally fail" do
    article = create(:submitted_news_article, images: [build(:image)])
    article.images.first.update_attribute(:alt_text, nil)
    NewsArticle.find(article.id).delete!
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

  test "should concatenate words containing apostrophes" do
    edition = create(:edition, title: "Bob's bike")
    assert_equal 'bobs-bike', edition.document.slug
  end

  test "is filterable by edition type" do
    policy = create(:policy)
    publication = create(:publication)
    news = create(:news_article)
    speech = create(:speech)
    consultation_response = create(:consultation_response)
    consultation = consultation_response.consultation

    assert_equal [policy], Edition.by_type('Policy')
    assert_equal [publication], Edition.by_type('Publication')
    assert_equal [news], Edition.by_type('NewsArticle')
    assert_equal [speech], Edition.by_type('Speech')
    assert_equal [consultation], Edition.by_type('Consultation')
    assert_equal [consultation_response], Edition.by_type('ConsultationResponse')
  end

  test "should not be featurable" do
    refute build(:edition).featurable?
  end

  test "should have no lead image even if an associated image exists" do
    article = build(:edition, images: [build(:image)])
    assert_nil article.lead_image
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

    results = Edition.search_index

    assert_equal 2, results.length
    assert_equal({"title"=>"policy-title", "link"=>"/government/policies/policy-title",
                  "indexable_content"=>"this and that", "format" => "policy",
                  "description" => "policy-summary"}, results[0])
    assert_equal({"title"=>"publication-title", "link"=>"/government/publications/publication-title",
                  "indexable_content"=>"stuff and things", "format" => "publication",
                  "description" => "publication-summary"}, results[1])
  end

  test "should add edition to search index on publishing" do
    policy = create(:submitted_policy)

    Rummageable.expects(:index).with(policy.search_index)

    policy.publish_as(create(:departmental_editor))
  end

  test "should not remove edition from search index when a new edition is published" do
    policy = create(:published_policy)
    slug = policy.document.slug

    Rummageable.expects(:delete).with("/government/policies/#{slug}").never

    new_edition = policy.create_draft(create(:policy_writer))
    new_edition.change_note = "change-note"
    new_edition.publish_as(create(:departmental_editor), force: true)
  end

  test "should not remove edition from search index when a new draft of a published edition is deleted" do
    policy = create(:published_policy)
    new_draft_policy = policy.create_draft(create(:policy_writer))
    slug = policy.document.slug

    Rummageable.expects(:delete).with("/government/policies/#{slug}").never

    new_draft_policy.delete!
  end

  test "should remove published edition from search index when it's deleted" do
    policy = create(:published_policy)
    slug = policy.document.slug

    Rummageable.expects(:delete).with("/government/policies/#{slug}")

    policy.delete!
  end

  test "should remove published edition from search index when it's archived" do
    policy = create(:published_policy)
    slug = policy.document.slug

    Rummageable.expects(:delete).with("/government/policies/#{slug}")

    policy.archive!
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

  test "#in_chronological_order returns docs order in ascending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Edition.in_chronological_order.all
  end

  test "#in_reverse_chronological_order returns docs order in descending order of first_published_at" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    mar = create(:edition, first_published_at: Date.parse("2011-03-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Edition.in_reverse_chronological_order.all
  end

  test "#published_before returns editions whose first_published_at is before the given date" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan], Edition.published_before("2011-01-29").all
  end

  test "#published_after returns editions whose first_published_at is after the given date" do
    jan = create(:edition, first_published_at: Date.parse("2011-01-01"))
    feb = create(:edition, first_published_at: Date.parse("2011-02-01"))
    assert_equal [feb], Edition.published_after("2011-01-29").all
  end

end
