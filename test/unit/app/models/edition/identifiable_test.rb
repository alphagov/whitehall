require "test_helper"

class Edition::IdentifiableTest < ActiveSupport::TestCase
  test "should set document type on document before validation for use in slug duplicate detection" do
    publication = build(:publication)
    publication.valid?
    assert_equal "Publication", publication.document.document_type
  end

  test "should not attempt to set document type if document is not present" do
    publication = build(:publication)
    publication.stubs(:document).returns(nil)
    assert_nothing_raised { publication.valid? }
  end

  test "should generate a content_id for the document of a new draft" do
    publication = build(:publication)
    publication.valid?
    assert publication.document.content_id.present?
  end

  test "should generate a content_id and slug on a document when present" do
    document = build(:document, content_id: nil)
    publication = build(:publication, document:)
    publication.valid?
    assert publication.document.content_id.present?
  end

  test "should be linkable when draft if document is published" do
    publication = create(:published_publication)
    new_edition = publication.create_draft(create(:writer))
    assert new_edition.linkable?
  end

  test "should not be linkable if document is not published" do
    publication = create(:draft_publication)
    assert_not publication.linkable?
  end

  test "should be linkable when superseded if document is published" do
    publication = create(:published_publication)
    new_edition = publication.create_draft(create(:writer))
    new_edition.minor_change = true
    force_publish(new_edition)
    assert publication.linkable?
  end

  test "should be linkable if scheduled to be published within 5 seconds" do
    date = Date.new(2010, 1, 1, 9)
    publication = create(:scheduled_publication, scheduled_publication: date)
    Timecop.freeze(date - 5.seconds) do
      assert publication.linkable?
    end
  end

  test "updating an edition updates the parent document timestamp" do
    edition = create(:edition)

    Timecop.travel 1.month do
      edition.update!(title: "Title updated")
      assert_equal edition.updated_at.to_i, edition.document.updated_at.to_i
    end
  end
end

class Edition::SluggingTest < ActiveSupport::TestCase
  class SluggableEdition < Edition
    def self.create!(attributes)
      super({
        document: Document.new,
        creator: User.new,
        previously_published: Time.zone.now,
        summary: "test",
        body: "test",
      }.merge(attributes))
    end

    def self.create_published!(attributes)
      create!({
        state: "published",
        major_change_published_at: 1.day.ago,
        change_note: "Important change",
      }.merge(attributes))
    end

  private

    def string_for_slug
      title
    end
  end

  setup do
    Flipflop::FeatureSet.current.test!.switch!(:slugs_for_editions, true)
  end

  teardown do
    Flipflop::FeatureSet.current.test!.switch!(:slugs_for_editions, false)
  end

  test "it does not update the slug if the `string_for_slug` method returns nil" do
    slug = "test-title"
    edition = SluggableEdition.create!(title: "Test Title", slug: slug)
    edition.stubs(:string_for_slug).returns(nil)
    edition.save!
    assert_equal slug, edition.slug
  end

  test "it applies the slug override if one is present" do
    first_edition = SluggableEdition.create_published!(title: "Original Title", slug: "original-title")
    second_edition = SluggableEdition.create!(title: "Draft Title", slug: "draft-title", slug_override: "original-title", document: first_edition.document)

    assert_equal first_edition.slug, second_edition.slug
    assert_equal "original-title", second_edition.slug
  end

  test "it updates the slug when the title changes" do
    edition = SluggableEdition.create!(title: "Original Title", slug: nil)
    original_slug = edition.slug
    edition.title = "New Title"
    edition.save!
    assert_not_equal original_slug, edition.slug
    assert_equal "new-title", edition.slug
  end

  test "it generates a unique slug when a duplicate exists of the same edition type" do
    first_edition = SluggableEdition.create!(title: "Same Title", slug: nil)
    second_edition = SluggableEdition.create!(title: "Same Title", slug: nil)

    assert_equal "same-title", first_edition.slug
    assert_equal "same-title--2", second_edition.slug
  end

  test "it generates a unique slug when two duplicates exist of the same edition type" do
    SluggableEdition.create!(title: "Same Title", slug: nil)
    SluggableEdition.create!(title: "Same Title", slug: nil)
    third_edition = SluggableEdition.create!(title: "Same Title", slug: nil)

    assert_equal "same-title--3", third_edition.slug
  end

  test "it generates a unique slug when a duplicate exists of a configurable document type with the same base path prefix" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("type_one")
                                                .merge(build_configurable_document_type("type_two")))

    first_edition = StandardEdition.create!(title: "Shared Title", type: "StandardEdition", configurable_document_type: "type_one", document: Document.new, creator: User.new, previously_published: Time.zone.now, summary: "test", body: "test", block_content: {})

    second_edition = StandardEdition.create!(title: "Shared Title", type: "StandardEdition", configurable_document_type: "type_two", document: Document.new, creator: User.new, previously_published: Time.zone.now, summary: "test", body: "test", block_content: {})

    assert_equal "shared-title", first_edition.slug
    assert_equal "shared-title--2", second_edition.slug
  end

  test "it normalizes special characters in slugs" do
    edition = SluggableEdition.create!(title: "Title with Special! Characters & Stuff", slug: nil)
    assert_match(/^[a-z0-9-]+$/, edition.slug)
  end

  test "it sets the slug to the document ID if the title language cannot be normalised" do
    document = create(:document)
    edition = SluggableEdition.create!(title: "英国驻华大使馆", slug: nil, document:)
    assert_equal(document.id.to_s, edition.slug)
  end

  test "it truncates slugs to 150 characters" do
    long_title = "a" * 200
    edition = SluggableEdition.create!(title: long_title, slug: nil)
    assert edition.slug.length <= 150
  end

  test "it allows same slug for different edition types" do
    Edition.create!(title: "Shared Title", type: "Edition", document: Document.new, creator: User.new, previously_published: Time.zone.now, summary: "test", body: "test")

    first_edition = SluggableEdition.create!(title: "Shared Title", slug: nil)

    assert_equal "shared-title", first_edition.slug
  end

  test "it allows same slug for configurable document edition types with different base path prefixes" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("type_one")
                                                .merge(build_configurable_document_type("type_two", {
                                                  "settings" => {
                                                    "base_path_prefix" => "/government/type_two",
                                                  },
                                                })))

    StandardEdition.create!(title: "Shared Title", type: "StandardEdition", configurable_document_type: "type_one", document: Document.new, creator: User.new, previously_published: Time.zone.now, summary: "test", body: "test", block_content: {})

    first_edition = StandardEdition.create!(title: "Shared Title", type: "StandardEdition", configurable_document_type: "type_two", document: Document.new, creator: User.new, previously_published: Time.zone.now, summary: "test", body: "test", block_content: {})

    assert_equal "shared-title", first_edition.slug
  end
end
