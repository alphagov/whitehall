require "test_helper"

class DocumentCollectionTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :document_collection, :title, :summary, :body

  test "groups should return related DocumentCollectionGroups ordered by document_collection_group.ordering" do
    doc_collection = create(
      :document_collection,
      groups: groups = [
        build(:document_collection_group),
        build(:document_collection_group),
        build(:document_collection_group),
      ],
    )
    groups[0].update!(ordering: 2)
    groups[1].update!(ordering: 1)
    groups[2].update!(ordering: 3)

    assert_equal [groups[1], groups[0], groups[2]], doc_collection.reload.groups
  end

  should_validate_with_safe_html_validator

  test "it should be invalid without a title" do
    assert_invalid build(:document_collection, title: nil)
  end

  test "it should be invalid without a summary" do
    assert_invalid build(:document_collection, summary: nil)
  end

  test "it should be valid without body text" do
    assert_valid build(:document_collection, body: nil)
  end

  test "it should be valid with a non-English primary locale" do
    doc_collection = build(:document_collection, groups: [])
    doc_collection.primary_locale = "cy"
    assert doc_collection.valid?
  end

  test "it should create a group called 'Documents' when created if groups are empty" do
    doc_collection = create(:document_collection, groups: [])
    assert_equal 1, doc_collection.groups.length
    assert_equal "Collection", doc_collection.groups[0].heading
  end

  test "it should not create a group if it's already been given one" do
    doc_collection = create(:document_collection, groups: [build(:document_collection_group, heading: "not documents")])
    assert_equal 1, doc_collection.groups.length
    assert_not_equal "Documents", doc_collection.groups[0].heading
  end

  def assert_collection_groups_are_the_same(original, draft)
    relevant_attributes = ->(g) { g.attributes.slice("heading", "body", "ordering") }
    original_attributes = original.groups.map(&relevant_attributes)
    draft_attributes = draft.groups.map(&relevant_attributes)

    assert_equal original_attributes, draft_attributes
  end

  test "#create_draft should clone the document collection and its constituent objects" do
    doc = create(:published_news_article).document

    original = create(
      :published_document_collection,
      groups: [
        build(:document_collection_group, documents: [doc]),
      ],
    )

    draft = original.create_draft(create(:gds_editor))
    assert_not_equal original.groups, draft.reload.groups

    assert_collection_groups_are_the_same(original, draft)

    assert_equal original.groups.map(&:documents), draft.groups.map(&:documents)
  end

  test "returns the title for slug string regardless of locale" do
    en_collection = create(:document_collection, groups: [])
    cy_collection = create(:document_collection, groups: [], primary_locale: "cy")

    [en_collection, cy_collection].each do |collection|
      assert_equal collection.document.slug, collection.title
    end
  end

  test "specifies the rendering app as frontend" do
    document_collection = DocumentCollection.new
    assert_equal Whitehall::RenderingApp::FRONTEND, document_collection.rendering_app
  end

  test "#content_ids returns content_ids from each group" do
    doc = create(:published_news_article).document
    non_whitehall_link = create(:document_collection_non_whitehall_link)
    groups = [
      build(:document_collection_group, documents: [doc]),
      build(:document_collection_group, non_whitehall_links: [non_whitehall_link]),
    ]
    doc_collection = create(:document_collection, groups:)

    assert_equal doc_collection.content_ids, [doc.content_id, non_whitehall_link.content_id]
  end

  test "#has_topic_level_notifications? returns true if taxonomy topic email override is present" do
    doc = create(:document_collection, taxonomy_topic_email_override: "some_content_id")
    assert doc.has_topic_level_notifications?
  end
end
