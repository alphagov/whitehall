require "test_helper"

class StandardEditionTranslationBlockContentConsistencyTest < ActiveSupport::TestCase

  def english_body_content = "English body content"
  def translated_body_content(locale) = "Body content for #{locale}"

  setup do
    ConfigurableDocumentType.setup_test_types(
      build_configurable_document_type("test", {
        "schema" => {
          "properties" => {
            "body" => { "type" => "string", "format" => "govspeak", "title" => "Body" },
            "image" => { "type" => "integer", "format" => "lead_image_select", "title" => "Lead image" },
          },
        },
        "settings" => { "translations_enabled" => true },
      })
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

  test "editions without images should not have image key in block_content" do
    translated_edition = create_standard_edition(translate_for: %w[cy])

    refute translated_edition.translation_for(:en).block_content.key?("image"),
           "English translation should not have image key"
    refute translated_edition.translation_for(:cy).block_content.key?("image"),
           "Welsh translation should not have image key"

    new_draft = translated_edition.create_draft(create(:writer))

    refute new_draft.translation_for(:en).block_content.key?("image"),
           "Draft English translation should not have image key"
    refute new_draft.translation_for(:cy).block_content.key?("image"),
           "Draft Welsh translation should not have image key"
  end

  test "primary translation with image should not clone image to non-primary translations" do
    standard_edition = create_standard_edition(with_image: true)
    create_translated_edition(standard_edition, locale: "cy", with_image: false)

    english_translation = standard_edition.translation_for(:en)
    welsh_translation = standard_edition.translation_for(:cy)
    image_id = english_translation.block_content["image"]

    refute welsh_translation.block_content.key?("image"),
           "Welsh translation should not have image key"

    new_draft = standard_edition.create_draft(create(:writer))

    assert_equal image_id, new_draft.translation_for(:en).block_content["image"],
                 "Draft English translation should have image value"

    assert new_draft.translation_for(:cy).block_content["image"].blank?,
           "Draft Welsh translation should not have a value but found Image ID: #{new_draft.translation_for(:cy).block_content["image"]}"
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

    assert_equal image_id, new_draft.translation_for(:cy).block_content["image"],
                 "Draft Welsh translation should have image value"
  end

  test "new draft editions with images get the translated image IDs from the parent" do
    standard_edition = create_standard_edition(with_image: true)
    create_translated_edition(standard_edition, locale: "cy", with_image: true)

    english_image_id = standard_edition.translation_for(:en).block_content["image"]
    welsh_image_id = standard_edition.translation_for(:cy).block_content["image"]

    new_draft = standard_edition.create_draft(create(:writer))

    assert_equal english_image_id, new_draft.translation_for(:en).block_content["image"],
           "Draft English translation should not have image value"

    assert_equal welsh_image_id, new_draft.translation_for(:cy).block_content["image"],
                 "Draft Welsh translation should have image value"
  end

private

  def create_standard_edition(with_image: false, translate_for: [])
    block_content = { "body" => english_body_content }
    block_content["image"] = create(:image).image_data.id if with_image

    standard_edition = create(
      :published_standard_edition,
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
