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
    assert_equal "Documents", doc_collection.groups[0].heading
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

  test "only indexes published collections" do
    assert_not create(:unpublished_document_collection).can_index_in_search?
    assert create(:published_document_collection).can_index_in_search?
  end

  test "indexes the title as title" do
    collection = create(:document_collection, title: "a title")
    assert_equal "a title", collection.search_index["title"]
  end

  test "indexes the full URL to the collection show page as link" do
    collection = create(:document_collection)
    assert_equal "/government/collections/#{collection.slug}", collection.search_index["link"]
  end

  test "indexes the slug" do
    collection = create(:published_document_collection)
    assert_equal collection.slug, collection.search_index["slug"]
  end

  test "returns the title for slug string regardless of locale" do
    en_collection = create(:document_collection, groups: [])
    cy_collection = create(:document_collection, groups: [], primary_locale: "cy")

    [en_collection, cy_collection].each do |collection|
      assert_equal collection.document.slug, collection.title
    end
  end

  test "indexes the body without markup as indexable_content" do
    collection = create(
      :document_collection,
      title: "A doc collection",
      body: "This is a *body*",
    )
    assert_match %r{^This is a body$}, collection.search_index["indexable_content"]
  end

  test "indexes the group headings and body copy without markup as indexable_content" do
    doc = create(:published_news_article).document
    empty_group = create(:document_collection_group, heading: "Empty Heading", body: "The *Body*")
    visible_group = create(:document_collection_group, heading: "The Heading", body: "The *Body*", documents: [doc])

    collection = create(:document_collection, groups: [empty_group, visible_group])

    assert_match %r{^The Heading$}, collection.search_index["indexable_content"]
    assert_no_match %r{^Empty Heading$}, collection.search_index["indexable_content"]
    assert_match %r{^The Body$}, collection.search_index["indexable_content"]
  end

  test "indexes the summary as description" do
    collection = create(:document_collection, summary: "a summary")
    assert_match "a summary", collection.search_index["description"]
  end

  test "specifies the rendering app as government frontend" do
    document_collection = DocumentCollection.new
    assert_equal Whitehall::RenderingApp::GOVERNMENT_FRONTEND, document_collection.rendering_app
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
end
