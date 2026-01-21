require "test_helper"

module PublishingApi
  module PayloadBuilder
    class ImagesTest < ActiveSupport::TestCase
      test "allows non-embeddable images that can be used" do
        type_key = "test_type_key"
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
          "settings" => {
            "images" => {
              "enabled" => true,
              "permitted_image_kinds" => [
                {
                  "kind" => "header",
                  "multiple" => false,
                },
                {
                  "kind" => "govspeak_embed",
                  "multiple" => true,
                },
              ],
            },
          },
        }))

        embeddable_image = create(:image)
        image = create(:image, image_data: create(:image_data, image_kind: "topical_event_header", file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))))
        document = create(:standard_edition, { configurable_document_type: type_key, images: [image, embeddable_image] })

        result = PayloadBuilder::Images.for(document)[:images]

        assert_equal 1, result.count
        assert_equal "header", result.first[:type]
      end

      test "allows multiple non-embeddable images that can be used if multiple use enabled for image kind" do
        type_key = "test_type_key"
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
          "settings" => {
            "images" => {
              "enabled" => true,
              "permitted_image_kinds" => [
                {
                  "kind" => "header",
                  "multiple" => true,
                },
              ],
            },
          },
        }))

        embeddable_image = create(:image)
        image = create(:image, image_data: create(:image_data, image_kind: "topical_event_header", file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg"))))
        another_image = create(:image, image_data: create(:image_data, image_kind: "topical_event_header", file: File.open(Rails.root.join("test/fixtures/images/another-test-svg.svg"))))
        document = create(:standard_edition, { configurable_document_type: type_key, images: [embeddable_image, image, another_image] })

        result = PayloadBuilder::Images.for(document)[:images]

        assert_equal 2, result.count
      end

      test "excludes images that cannot be used" do
        type_key = "test_type_key"
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type(type_key, {
          "settings" => {
            "images" => {
              "enabled" => true,
              "permitted_image_kinds" => [
                {
                  "kind" => "header",
                  "multiple" => false,
                },
              ],
            },
          },
        }))

        unsupported_image = create(:image, image_data: build(:hero_image_data, image_kind: "hero_desktop", file: upload_fixture("hero_image_desktop_2x.png", "image/png")))
        uncropped_image = create(:image, image_data: create(:image_data, image_kind: "topical_event_header", file: File.open(Rails.root.join("test/fixtures/images/960x960_jpeg.jpg"))))
        uncropped_image.image_data.stubs(:requires_crop?).returns(true) # due to inconsistent factory behaviour :(
        image_without_assets = create(:image, image_data: create(:image_data, image_kind: "topical_event_header", file: File.open(Rails.root.join("test/fixtures/images/960x640_gif.gif"))))
        image_without_assets.image_data.stubs(:all_asset_variants_uploaded?).returns(false)

        document = create(:standard_edition, { configurable_document_type: type_key, images: [unsupported_image, uncropped_image] })
        assert_not PayloadBuilder::Images.for(document)[:images]
      end
    end
  end
end
