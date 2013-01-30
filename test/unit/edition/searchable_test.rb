require "test_helper"

class Edition::SearchableTest < ActiveSupport::TestCase

  test "should return search index suitable for Rummageable" do
    edition = create(:published_edition, title: "edition-title", organisations: [create(:organisation)])

    assert_equal "edition-title", edition.search_index["title"]
    assert_equal routes_helper.public_document_path(edition), edition.search_index["link"]
    assert_equal edition.body, edition.search_index["indexable_content"]
    assert_equal "generic_edition", edition.search_index["format"]
    assert_equal edition.summary, edition.search_index["description"]
    assert_equal edition.id, edition.search_index["id"]
    assert_equal edition.organisations.map(&:id), edition.search_index["organisations"]
    assert_equal nil, edition.search_index["people"]
    assert_equal nil, edition.search_index["publication_type"]
    assert_equal nil, edition.search_index["speech_type"]
    assert_equal edition.public_timestamp, edition.search_index["public_timestamp"]
    assert_equal nil, edition.search_index["topics"]
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

    Rummageable.expects(:index).with(has_entry("id", edition.id), Whitehall.government_search_index_path)

    edition.publish_as(create(:departmental_editor))
  end

  test "should not remove edition from search index when a new edition is published" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Rummageable.expects(:delete).with("/government/policies/#{slug}", Whitehall.government_search_index_path).never

    new_edition = edition.create_draft(create(:policy_writer))
    new_edition.change_note = "change-note"
    new_edition.publish_as(create(:departmental_editor), force: true)
  end

  test "should not remove edition from search index when a new draft of a published edition is deleted" do
    edition = create(:published_edition)
    new_draft_edition = edition.create_draft(create(:policy_writer))
    slug = edition.document.slug

    Rummageable.expects(:delete).with(routes_helper.public_document_path(edition), Whitehall.government_search_index_path).never

    new_draft_edition.delete!
  end

  test "should remove published edition from search index when it's unpublished" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Rummageable.expects(:delete).with(routes_helper.public_document_path(edition), Whitehall.government_search_index_path)

    edition.unpublish_as(create(:gds_editor))
  end

  test "should remove published edition from search index when it's archived" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Rummageable.expects(:delete).with(routes_helper.public_document_path(edition), Whitehall.government_search_index_path)

    edition.archive!
  end
end