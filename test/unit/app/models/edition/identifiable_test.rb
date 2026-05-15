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
  extend Minitest::Spec::DSL

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

  # Edition state is not listed in UNMODIFIABLE_STATES; edition can be generally edited, including title changes.
  describe "modifiable edition slug behaviour" do
    test "it does not update the slug if the `string_for_slug` method returns nil" do
      slug = "test-title"
      edition = SluggableEdition.create!(title: "Test Title", slug: slug)
      edition.stubs(:string_for_slug).returns(nil)
      edition.save!
      assert_equal slug, edition.slug
    end

    test "it updates the slug and slug_from_title when the title changes and override is nil" do
      edition = SluggableEdition.create!(title: "Original Title", slug_override: nil)
      original_slug = edition.slug
      edition.title = "New Title"
      edition.save!
      assert_not_equal original_slug, edition.slug
      assert_equal "new-title", edition.slug
      assert_equal "new-title", edition.slug_from_title
    end

    test "it updates the slug and slug_from_title when the title changes and override is blank" do
      edition = SluggableEdition.create!(title: "Original Title", slug_override: "")
      original_slug = edition.slug
      edition.title = "New Title"
      edition.save!
      assert_not_equal original_slug, edition.slug
      assert_equal "new-title", edition.slug
      assert_equal "new-title", edition.slug_from_title
    end

    test "it applies the slug override to a draft, if override present" do
      draft_edition = SluggableEdition.create!(title: "Original Title")
      draft_edition.slug_override = "original-title-override"
      draft_edition.save!
      assert_equal "original-title-override", draft_edition.slug
    end

    test "it clears slug_override when the new title makes it redundant" do
      edition = SluggableEdition.create!(title: "Original Title", slug_override: "chosen-slug")
      assert_equal "chosen-slug", edition.slug

      edition.update!(title: "Chosen slug")

      assert_nil edition.slug_override
      assert_equal "chosen-slug", edition.slug
    end

    test "it clears slug_override if it matches slug_from_title" do
      edition = SluggableEdition.create_published!(title: "Klingons rule")
      draft = edition.create_draft(create(:writer))
      draft.update!(slug_override: "klingons-rule", change_note: "Important change")

      assert_nil draft.slug_override
      assert_equal "klingons-rule", draft.slug
    end

    test "it clears slug_override for whitespace stripped title that matches original title" do
      title_with_whitespace = "Klingons rule "
      edition = SluggableEdition.create!(title: "Klingons rule", slug_override: "klingons-rule")
      edition.update!(title: title_with_whitespace)

      assert_nil edition.slug_override
      assert_equal "klingons-rule", edition.slug
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

    test "it reuses a slug if it becomes available" do
      clashing_draft = SluggableEdition.create!(title: "Original Title")
      draft_edition = SluggableEdition.create!(title: "Original Title")
      assert_equal "original-title", clashing_draft.slug
      assert_equal "original-title--2", draft_edition.slug

      clashing_draft.destroy!
      another_draft_edition = SluggableEdition.create!(title: "Original Title")

      assert_equal "original-title", another_draft_edition.slug
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

  # Edition state is listed in UNMODIFIABLE_STATES. Changing the title or the override requires skipping validations.
  describe "unmodifiable edition slug behaviour" do
    test "updates slug for published editions when saved with validate: false, if slug_from_title changes" do
      published_edition = SluggableEdition.create_published!(title: "Original Title")
      assert_equal "original-title", published_edition.slug
      assert_equal "original-title", published_edition.slug_from_title

      published_edition.title = "New title"
      published_edition.save!(validate: false)

      published_edition.reload
      assert_equal "new-title", published_edition.slug
      assert_equal "new-title", published_edition.slug_from_title
    end

    test "updates slug for published editions when saved with validate: false, if override changes" do
      published_edition = SluggableEdition.create_published!(title: "Original Title")
      assert_equal "original-title", published_edition.slug
      assert_equal "original-title", published_edition.slug_from_title

      published_edition.slug_override = "slug-override"
      published_edition.save!(validate: false)

      published_edition.reload
      assert_equal "slug-override", published_edition.slug
      assert_equal "slug-override", published_edition.slug_override
    end

    test "it preservers the slug state from the published edition when redrafting" do
      published_edition = SluggableEdition.create_published!(title: "Original Title", slug_override: "original-title-override")
      assert_equal "original-title-override", published_edition.slug

      draft_edition_with_slug_override = published_edition.create_draft(create(:writer))

      assert_equal "original-title-override", draft_edition_with_slug_override.slug
      assert_equal "original-title-override", draft_edition_with_slug_override.slug_override
    end

    test "it applies the slug override to a draft from published, if override present" do
      published_edition = SluggableEdition.create_published!(title: "Original Title")
      draft_edition_with_slug_override = published_edition.create_draft(create(:writer))
      draft_edition_with_slug_override.slug_override = "original-title-override"
      draft_edition_with_slug_override.save!(validate: false) # skip change note validation

      assert_equal "original-title", published_edition.slug
      assert_equal "original-title-override", draft_edition_with_slug_override.slug
      assert_equal "original-title-override", draft_edition_with_slug_override.slug_override
    end
  end
end
