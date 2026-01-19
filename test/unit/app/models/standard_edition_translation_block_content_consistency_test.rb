require "test_helper"

class StandardEditionTranslationBlockContentConsistencyTest < ActiveSupport::TestCase
  def english_body_content = "English body content"
  def translated_body_content(locale) = "Body content for #{locale}"

  setup do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type(
        "test", {
          "schema" => {
            "attributes" => {
              "body" => { "type" => "string" },
              "image" => { "type" => "integer" },
            },
          },
          "settings" => { "translations_enabled" => true },
        }
      ),
    )
  end

  test "creating a new draft from a published StandardEdition with translations should not duplicate old body field data" do
    translated_edition = create_standard_edition(translate_for: %w[cy])

    new_draft = translated_edition.create_draft(create(:writer))

    english_translation = new_draft.translation_for(:en)
    welsh_translation = new_draft.translation_for(:cy)

    assert_nil english_translation[:body],
               "English translation body column should be nil, but got: #{english_translation[:body]}"
    assert_nil welsh_translation[:body],
               "Welsh translation body column should be nil, but got: #{welsh_translation[:body]}"

    assert_equal english_body_content, english_translation.block_content["body"],
                 "English body should be in block_content.body"
    assert_equal translated_body_content("cy"), welsh_translation.block_content["body"],
                 "Welsh body should be in block_content.body"
  end

  test "editions without images should have `nil` image key in block_content" do
    translated_edition = create_standard_edition(translate_for: %w[cy])

    assert_nil translated_edition.translation_for(:en).block_content["image"],
               "English translation should not have image key"
    assert_nil translated_edition.translation_for(:cy).block_content["image"],
               "Welsh translation should not have image key"

    new_draft = translated_edition.create_draft(create(:writer))

    assert_nil new_draft.translation_for(:en).block_content["image"],
               "Draft English translation should not have image key"
    assert_nil new_draft.translation_for(:cy).block_content["image"],
               "Draft Welsh translation should not have image key"
  end

  test "primary translation with image should not clone image to non-primary translations" do
    standard_edition = create_standard_edition(with_image: true)
    create_translated_edition(standard_edition, locale: "cy", with_image: false)

    english_translation = standard_edition.translation_for(:en)
    welsh_translation = standard_edition.translation_for(:cy)
    image_id = english_translation.block_content["image"]

    assert_equal english_body_content, english_translation.block_content["body"],
                 "English body should have correct content"
    assert_equal translated_body_content("cy"), welsh_translation.block_content["body"],
                 "Welsh body should have correct content"
    assert_not_includes welsh_translation.block_content.keys, "image",
                        "Welsh translation should not have image key"

    new_draft = standard_edition.create_draft(create(:writer))

    assert_equal image_id, new_draft.translation_for(:en).block_content["image"],
                 "Draft English translation should have image value"
    assert_equal english_body_content, new_draft.translation_for(:en).block_content["body"],
                 "Draft English body should have correct content"

    assert new_draft.translation_for(:cy).block_content["image"].blank?,
           "Draft Welsh translation should not have a value but found Image ID: #{new_draft.translation_for(:cy).block_content['image']}"
    assert_equal translated_body_content("cy"), new_draft.translation_for(:cy).block_content["body"],
                 "Draft Welsh body should have correct content"
  end

  test "translated edition with image should not clone to primary translation" do
    standard_edition = create_standard_edition(with_image: false)
    create_translated_edition(standard_edition, locale: "cy", with_image: true)

    english_translation = standard_edition.translation_for(:en)
    welsh_translation = standard_edition.translation_for(:cy)
    image_id = welsh_translation.block_content["image"]

    new_draft = standard_edition.create_draft(create(:writer))

    assert english_translation.block_content["image"].blank?,
           "Draft English translation should not have image value"
    assert_equal english_body_content, new_draft.translation_for(:en).block_content["body"],
                 "Draft English body should have correct content"

    assert_equal image_id, new_draft.translation_for(:cy).block_content["image"],
                 "Draft Welsh translation should have image value"
    assert_equal translated_body_content("cy"), new_draft.translation_for(:cy).block_content["body"],
                 "Draft Welsh body should have correct content"
  end

  test "new draft editions with images get the translated image IDs from the parent" do
    standard_edition = create_standard_edition(with_image: true)
    create_translated_edition(standard_edition, locale: "cy", with_image: true)

    english_image_id = standard_edition.translation_for(:en).block_content["image"]
    welsh_image_id = standard_edition.translation_for(:cy).block_content["image"]

    new_draft = standard_edition.create_draft(create(:writer))

    assert_equal english_image_id, new_draft.translation_for(:en).block_content["image"],
                 "Draft English translation should have image value"
    assert_equal english_body_content, new_draft.translation_for(:en).block_content["body"],
                 "Draft English body should have correct content"

    assert_equal welsh_image_id, new_draft.translation_for(:cy).block_content["image"],
                 "Draft Welsh translation should have image value"
    assert_equal translated_body_content("cy"), new_draft.translation_for(:cy).block_content["body"],
                 "Draft Welsh body should have correct content"
  end

  test "new draft with multiple translations each having images retains correct data per locale" do
    standard_edition = create_standard_edition(with_image: true)
    create_translated_edition(standard_edition, locale: "cy", with_image: true)
    create_translated_edition(standard_edition, locale: "fr", with_image: true)

    english_image_id = standard_edition.translation_for(:en).block_content["image"]
    welsh_image_id = standard_edition.translation_for(:cy).block_content["image"]
    french_image_id = standard_edition.translation_for(:fr).block_content["image"]

    # Ensure all images are distinct
    assert_not_equal english_image_id, welsh_image_id, "English and Welsh should have different images"
    assert_not_equal english_image_id, french_image_id, "English and French should have different images"
    assert_not_equal welsh_image_id, french_image_id, "Welsh and French should have different images"

    new_draft = standard_edition.create_draft(create(:writer))

    # Verify each locale retains its own image
    assert_equal english_image_id, new_draft.translation_for(:en).block_content["image"],
                 "Draft English translation should have its original image"
    assert_equal welsh_image_id, new_draft.translation_for(:cy).block_content["image"],
                 "Draft Welsh translation should have its original image"
    assert_equal french_image_id, new_draft.translation_for(:fr).block_content["image"],
                 "Draft French translation should have its original image"

    # Verify body content is also correct per locale
    assert_equal english_body_content, new_draft.translation_for(:en).block_content["body"],
                 "Draft English body should have correct content"
    assert_equal translated_body_content("cy"), new_draft.translation_for(:cy).block_content["body"],
                 "Draft Welsh body should have correct content"
    assert_equal translated_body_content("fr"), new_draft.translation_for(:fr).block_content["body"],
                 "Draft French body should have correct content"
  end

  test "partial updates to block_content merge correctly within primary translation" do
    draft_standard_edition = create_standard_edition(with_image: false, factory_name: :draft_standard_edition)

    I18n.with_locale(:en) do
      draft_standard_edition.block_content = { "image" => 123 }
      draft_standard_edition.save!
    end

    draft_standard_edition.reload
    primary_translation = draft_standard_edition.translation_for(:en)

    assert_equal english_body_content, primary_translation.block_content["body"],
                 "Body should be preserved after partial update"
    assert_equal 123, primary_translation.block_content["image"],
                 "Image should be added via partial update"
  end

  test "partial updates to block_content merge correctly within secondary translation" do
    draft_standard_edition = create_standard_edition(with_image: false, factory_name: :draft_standard_edition)
    create_translated_edition(draft_standard_edition, locale: "cy", with_image: false)

    I18n.with_locale(:cy) do
      draft_standard_edition.block_content = { "image" => 123 }
      draft_standard_edition.save!
    end

    draft_standard_edition.reload
    secondary_translation = draft_standard_edition.translation_for(:cy)

    assert_equal translated_body_content(:cy), secondary_translation.block_content["body"],
                 "Body should be preserved after partial update"
    assert_equal 123, secondary_translation.block_content["image"],
                 "Image should be added via partial update"
  end

  test "partial updates to block_content in translated locales do not affect primary translation" do
    draft_standard_edition = create_standard_edition(with_image: false, factory_name: :draft_standard_edition)
    create_translated_edition(draft_standard_edition, locale: "cy", with_image: false)

    I18n.with_locale(:cy) do
      draft_standard_edition.block_content = { "body" => "this is the updated translated version" }
      draft_standard_edition.save!
    end

    draft_standard_edition.reload

    primary_translation = draft_standard_edition.translation_for(:en)
    assert_equal english_body_content, primary_translation.block_content["body"],
                 "Body should be preserved after partial update"
  end

  test "partial updates to block_content in primary locale do not affect secondary translations" do
    draft_standard_edition = create_standard_edition(with_image: false, factory_name: :draft_standard_edition)
    create_translated_edition(draft_standard_edition, locale: "cy", with_image: false)

    I18n.with_locale(:en) do
      draft_standard_edition.block_content = { "body" => "this is the updated english version" }
      draft_standard_edition.save!
    end

    draft_standard_edition.reload

    secondary_translation = draft_standard_edition.translation_for(:cy)
    assert_equal translated_body_content(:cy), secondary_translation.block_content["body"],
                 "Body should be preserved after partial update"
  end

private

  def create_standard_edition(with_image: false, translate_for: [], factory_name: :published_standard_edition)
    block_content = { "body" => english_body_content }
    block_content["image"] = create(:image).image_data.id if with_image

    standard_edition = create(
      factory_name,
      configurable_document_type: "test",
      title: "English title",
      summary: "English summary",
      block_content:,
    )

    translate_for.each { |locale| create_translated_edition(standard_edition, locale:) }

    standard_edition
  end

  def create_translated_edition(standard_edition, locale:, with_image: false)
    block_content = { "body" => translated_body_content(locale) }
    block_content["image"] = create(:image).image_data.id if with_image

    I18n.with_locale(locale) { standard_edition.translations.create!(locale:, block_content:) }
  end
end
