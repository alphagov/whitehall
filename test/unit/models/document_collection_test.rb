require "test_helper"

class DocumentCollectionTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :title, :summary, :body

  test "groups should return related DocumentCollectionGroups ordered by document_collection_group.ordering" do
    doc_collection = create(:document_collection, groups: groups = [
      build(:document_collection_group),
      build(:document_collection_group),
      build(:document_collection_group)
    ])
    groups[0].update_attribute(:ordering, 2)
    groups[1].update_attribute(:ordering, 1)
    groups[2].update_attribute(:ordering, 3)

    assert_equal [groups[1], groups[0], groups[2]], doc_collection.reload.groups
  end

  test "editions lists all editions associated through the document collection' groups" do
    doc_collection = create(:document_collection)

    pub_1 = create(:publication)
    pub_2 = create(:publication)

    group_1 = create(:document_collection_group, document_collection: doc_collection, documents: [pub_1.document])
    group_2 = create(:document_collection_group, document_collection: doc_collection, documents: [pub_2.document])

    assert doc_collection.editions.include? pub_1
    assert doc_collection.editions.include? pub_2
  end

  should_validate_with_safe_html_validator

  test "it should be invalid without a title" do
    assert_invalid build(:document_collection, title: nil)
  end

  test "it should be invalid without a summary" do
    assert_invalid build(:document_collection, summary: nil)
  end

  test "it should be invalid without body text" do
    assert_invalid build(:document_collection, body: nil)
  end

  test "it should create a group called 'Documents' when created if groups are empty" do
    doc_collection = create(:document_collection, groups: [])
    assert_equal 1, doc_collection.groups.length
    assert_equal "Documents", doc_collection.groups[0].heading
  end

  test "it should not create a group if it's already been given one" do
    doc_collection = create(:document_collection, groups: [build(:document_collection_group, heading: 'not documents')])
    assert_equal 1, doc_collection.groups.length
    refute_equal "Documents", doc_collection.groups[0].heading
  end

  def assert_collection_groups_are_the_same(original, draft)
    relevant_attributes = ->(g) { g.attributes.slice('heading', 'body', 'ordering') }
    original_attributes = original.groups.map(&relevant_attributes)
    draft_attributes = draft.groups.map(&relevant_attributes)

    assert_equal original_attributes, draft_attributes
  end

  test "#create_draft should clone the document collection and its constituent objects" do
    doc = create(:published_news_article).document

    original = create(:published_document_collection, groups: [
      build(:document_collection_group, documents: [doc])
    ])

    draft = original.create_draft(create(:gds_editor))

    assert_not_equal original.groups, draft.groups

    assert_collection_groups_are_the_same(original, draft)

    assert_equal original.groups.map(&:documents), draft.groups.map(&:documents)
  end

  test "only indexes published collections" do
    refute create(:unpublished_document_collection).can_index_in_search?
    assert create(:published_document_collection).can_index_in_search?
  end

  test 'indexes the title as title' do
    collection = create(:document_collection, title: 'a title')
    assert_equal 'a title', collection.search_index['title']
  end

  test 'indexes the full URL to the collection show page as link' do
    collection = create(:document_collection)
    assert_equal "/government/collections/#{collection.slug}", collection.search_index['link']
  end

  test "indexes the body without markup as indexable_content" do
    collection = create(:document_collection,
                    title: "A doc collection", body: "This is a *body*")
    assert_match /^This is a body$/, collection.search_index["indexable_content"]
  end

  test 'indexes the group headings and body copy without markup as indexable_content' do
    group = create(:document_collection_group, heading: 'The Heading', body: 'The *Body*')
    collection = create(:document_collection, groups: [group])
    assert_match /^The Heading$/, collection.search_index['indexable_content']
    assert_match /^The Body$/, collection.search_index['indexable_content']
  end

  test 'indexes the summary as description' do
    collection = create(:document_collection, summary: 'a summary')
    assert_match 'a summary', collection.search_index['description']
  end

  test 'published_editions returns published editions from collection in reverse chronological order' do
    collection = create(:document_collection, :with_group)
    draft = create(:draft_publication)
    old = create(:published_publication, first_published_at: 2.days.ago)
    new = create(:published_publication, first_published_at: 1.day.ago)
    group = collection.groups.first
    group.documents = [draft.document, old.document, new.document]

    assert_equal [new, old], collection.published_editions
  end

  test 'scheduled_editions returns editions that are scheduled for publishing in the collection' do
    collection = create(:document_collection, :with_group)
    publication = create(:published_publication, first_published_at: 2.days.ago)
    scheduled_publication = create(:scheduled_publication)
    group = collection.groups.first
    group.documents = [scheduled_publication.document, publication.document]

    assert_equal [scheduled_publication], collection.scheduled_editions
  end
end
