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
    document = build(:document, content_id: nil, slug: nil)
    publication = build(:publication, document:)
    publication.valid?
    assert publication.document.content_id.present?
    assert publication.document.slug.present?
  end

  test "should not allow the same slug to be used again for the same document type" do
    same_title = "same-title"
    publication1 = create(:publication, title: same_title)
    publication2 = create(:publication, title: same_title)

    assert_not_equal publication1.document.slug, publication2.document.slug
  end

  test "should allow the same slug to be used again for another document type" do
    same_title = "same-title"
    publication = create(:publication, title: same_title)
    another_type = create(:speech, title: same_title)

    assert_equal publication.document.slug, another_type.document.slug
  end

  test "should return the edition of the correct type when matching slugs for other types exist" do
    same_title = "same-title"
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    standard_edition = create(:published_standard_edition, title: same_title)
    publication = create(:published_publication, title: same_title)

    assert_equal standard_edition, StandardEdition.published_as(same_title)
    assert_equal publication, Publication.published_as(same_title)
  end

  test "should return nil if the edition isn't translated into the supplied locale" do
    publication = create(:published_publication, translated_into: "fr")

    assert_nil Publication.published_as(publication.slug, "zh")
  end

  test "should return the edition if it is translated into the supplied locale" do
    publication = create(:published_publication, translated_into: "fr")

    assert_equal publication, Publication.published_as(publication.slug, "fr")
  end

  test "should return the edition if it is translated into the default locale when none is specified" do
    publication = create(:published_publication, translated_into: I18n.default_locale)

    assert_equal publication, Publication.published_as(publication.slug)
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

  test "update slug if title changes on draft edition" do
    publication = create(:draft_publication, title: "This is my publication")
    publication.update!(title: "Another thing")

    assert_equal "another-thing", publication.document.reload.slug
  end

  test "do not update slug if non-english title changes on draft edition" do
    publication = create(:draft_publication, title: "This is my publication")
    with_locale(:es) do
      publication.update!(title: "Spanish thing", summary: "Avoid validation error", body: "Avoid validation error")
    end

    assert_equal "this-is-my-publication", publication.document.reload.slug
  end

  test "should not update the slug of an existing edition when saved in the presence of a new edition with the same title" do
    existing_edition = create(:draft_publication, title: "This is my publication")
    assert_equal "this-is-my-publication", existing_edition.document.reload.slug

    new_edition_with_same_title = create(:draft_publication, title: "This is my publication")
    assert_equal "this-is-my-publication--2", new_edition_with_same_title.document.reload.slug

    existing_edition.save!
    assert_equal "this-is-my-publication", existing_edition.document.reload.slug
  end

  test "should not update slug when after an edition has been unpublished" do
    unpublished_edition = create(:superseded_publication, title: "This is my publication")
    draft_edition = create(:draft_publication, title: "This is my publication", document: unpublished_edition.document)

    draft_edition.title = "New title"
    draft_edition.save!
    assert_equal "this-is-my-publication", draft_edition.document.reload.slug
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
