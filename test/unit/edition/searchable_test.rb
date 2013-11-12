require "test_helper"

class Edition::SearchableTest < ActiveSupport::TestCase

  test "should return search index suitable for Rummageable" do
    edition = create(:published_edition, title: "edition-title")

    assert_equal "edition-title", edition.search_index["title"]
    assert_equal routes_helper.public_document_path(edition), edition.search_index["link"]
    assert_equal edition.body, edition.search_index["indexable_content"]
    assert_equal "generic_edition", edition.search_index["format"]
    assert_equal edition.summary, edition.search_index["description"]
    assert_equal edition.id, edition.search_index["id"]
    assert_equal nil, edition.search_index["organisations"]
    assert_equal nil, edition.search_index["people"]
    assert_equal nil, edition.search_index["publication_type"]
    assert_equal nil, edition.search_index["speech_type"]

    assert_equal edition.public_timestamp, edition.search_index["public_timestamp"]
    assert_equal nil, edition.search_index["topics"]
  end

  test 'search_index contains the value of relevant_to_local_government?' do
    edition = create(:published_edition, relevant_to_local_government: false)
    relevancy = stub("relevancy")
    edition.stubs(:relevant_to_local_government?).returns(relevancy)

    assert_equal relevancy, edition.search_index['relevant_to_local_government']
  end

  test "#indexable_content should return the body without markup by default" do
    edition = create(:published_edition, body: "# header\n\nsome text")
    assert_equal "header some text", edition.indexable_content
  end

  test "should use the result of #indexable_content for the content of #search_index" do
    edition = create(:published_edition, title: "edition-title")
    edition.stubs(:indexable_content).returns("some augmented searchable content")
    assert_equal "some augmented searchable content", edition.search_index["indexable_content"]
  end

  test "should add edition to search index on publishing" do
    edition = create(:submitted_edition)
    Whitehall.stubs(:searchable_classes).returns([edition.class])
    Searchable::Index.expects(:later).with(edition)

    Whitehall.edition_services.publisher(edition).perform!
  end

  test "should not add edition to search index if it is not available in English" do
    I18n.locale = :fr
    french_edition = create(:submitted_edition, title: 'French Title', body: 'French Body', locale: :fr)
    I18n.locale = I18n.default_locale
    Whitehall.stubs(:searchable_classes).returns([french_edition.class])
    Searchable::Index.expects(:later).with(french_edition).never

    Whitehall.edition_services.publisher(french_edition).perform!
  end

  test "should not remove edition from search index when a new edition is published" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Searchable::Delete.expects(:later).with(edition).never

    new_edition = edition.create_draft(create(:policy_writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)
  end

  test "should not remove edition from search index when a new draft of a published edition is deleted" do
    edition = create(:published_edition)
    new_draft_edition = edition.create_draft(create(:policy_writer))
    slug = edition.document.slug

    Searchable::Delete.expects(:later).with(edition).never

    new_draft_edition.delete!
  end

  test "should remove published edition from search index when it's unpublished" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Searchable::Delete.expects(:later).with(edition)
    edition.unpublishing = build(:unpublishing)
    Whitehall.edition_services.unpublisher(edition).perform!
  end
end
