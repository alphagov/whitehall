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
    assert_equal edition.live_specialist_sector_tags, edition.search_index["specialist_sectors"]
    assert_equal edition.most_recent_change_note, edition.search_index["latest_change_note"]
    assert_equal nil, edition.search_index["organisations"]
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
    stub_panopticon_registration(edition)
    stub_publishing_api_registration_for(edition)
    Whitehall.stubs(:searchable_classes).returns([edition.class])
    Whitehall::SearchIndex.expects(:add).with(edition)

    Whitehall.edition_services.publisher(edition).perform!
  end

  test "should add latest change note to search index" do
    user  = create(:gds_editor)
    first = create(:published_edition)

    major = first.create_draft(user)
    major.change_note = 'This was a major change'
    force_publish(major)

    assert_equal "This was a major change", major.search_index["latest_change_note"]
  end

  test "should not add edition to search index if it is not available in English" do
    I18n.locale = :fr
    french_edition = create(:submitted_edition, title: 'French Title', body: 'French Body', locale: :fr)
    I18n.locale = I18n.default_locale
    stub_panopticon_registration(french_edition)
    stub_publishing_api_registration_for(french_edition)
    Whitehall.stubs(:searchable_classes).returns([french_edition.class])
    Whitehall::SearchIndex.expects(:add).with(french_edition).never

    Whitehall.edition_services.publisher(french_edition).perform!
  end

  test "should not remove edition from search index when a new edition is published" do
    edition = create(:published_edition)
    slug = edition.document.slug

    Whitehall::SearchIndex.expects(:delete).with(edition).never

    new_edition = edition.create_draft(create(:policy_writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)
  end

  test "should remove published edition from search index when it's unpublished" do
    edition = create(:published_edition)
    slug = edition.document.slug
    stub_panopticon_registration(edition)

    Whitehall::SearchIndex.expects(:delete).with(edition)
    edition.unpublishing = build(:unpublishing, edition: nil)
    Whitehall.edition_services.unpublisher(edition).perform!
  end
end
