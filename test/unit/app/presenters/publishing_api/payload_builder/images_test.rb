require "test_helper"

module PublishingApi
  module PayloadBuilder
    class ImagesTest < ActiveSupport::TestCase
      test "allows only non-embeddable images" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "govspeak_embed" => {
                  "kinds" => %w[some_embeddable_kind],
                  "multiple" => true,
                },
                "non_embeddable_usage" => {
                  "kinds" => %w[non_embeddable_usage_kind],
                  "multiple" => false,
                },
              },
            },
          },
        }))

        embeddable_image = create(:image, :jpg, usage: "govspeak_embed")
        non_embeddable_image = create(:image, :svg, usage: "non_embeddable_usage", caption: "A non-embeddable image")
        page = create(:standard_edition, images: [embeddable_image, non_embeddable_image])

        result = PayloadBuilder::Images.for(page)[:images]

        assert_equal 1, result.count
        assert non_embeddable_image.can_be_used?
        assert_equal non_embeddable_image.usage, result.first[:type]
      end

      test "allows only images with usages configured in the schema" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "allowed_non_embeddable_usage" => {
                  "kinds" => %w[allowed_non_embeddable_usage_kind],
                  "multiple" => false,
                },
              },
            },
          },
        }))

        allowed_image = create(:image, :svg, usage: "allowed_non_embeddable_usage")
        image_with_usage_not_allowed_in_schema = create(:image, :svg, usage: "usage_not_in_schema")
        page = create(:standard_edition, images: [allowed_image, image_with_usage_not_allowed_in_schema])

        result = PayloadBuilder::Images.for(page)[:images]

        assert_equal 1, result.count
        assert_equal allowed_image.usage, result.first[:type]
      end

      test "excludes images that cannot be used due to requiring cropping or missing assets" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "non_embeddable_usage" => {
                  "kinds" => %w[non_embeddable_usage_kind],
                  "multiple" => false,
                },
              },
            },
          },
        }))

        uncropped_image = create(:image, :jpg, usage: "non_embeddable_usage")
        uncropped_image.image_data.stubs(:requires_crop?).returns(true)
        image_without_assets = create(:image, :with_no_assets, usage: "non_embeddable_usage")
        page = create(:standard_edition, images: [uncropped_image, image_without_assets])

        assert_not PayloadBuilder::Images.for(page)[:images]
      end

      test "allows multiple non-embeddable images, if 'multiple' is enabled for the usage" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "allowed_non_embeddable_usage" => {
                  "kinds" => %w[allowed_non_embeddable_usage_kind],
                  "multiple" => true,
                },
              },
            },
          },
        }))

        image = create(:image, :jpg, usage: "allowed_non_embeddable_usage")
        another_image = create(:image, :svg, usage: "allowed_non_embeddable_usage")
        page = create(:standard_edition, images: [image, another_image])

        result = PayloadBuilder::Images.for(page)[:images]

        assert_equal 2, result.count
        assert_equal [image.usage, another_image.usage], result.pluck(:type)
      end

      test "allows multiple non-embeddable images, across multiple usages" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "non_embeddable_usage_one" => {
                  "kinds" => %w[non_embeddable_usage_one_kind],
                  "multiple" => true,
                },
                "non_embeddable_usage_two" => {
                  "kinds" => %w[non_embeddable_usage_two_kind],
                  "multiple" => true,
                },
              },
            },
          },
        }))

        usage_one_image = create(:image, usage: "non_embeddable_usage_one")
        another_usage_one_image = create(:image, usage: "non_embeddable_usage_one")
        usage_two_image = create(:image, usage: "non_embeddable_usage_two")
        another_usage_two_image = create(:image, usage: "non_embeddable_usage_two")
        page = create(:standard_edition, images: [usage_one_image, another_usage_one_image, usage_two_image, another_usage_two_image])

        result = PayloadBuilder::Images.for(page)[:images]

        assert_equal 4, result.count
        assert_equal [usage_one_image.usage, another_usage_one_image.usage, usage_two_image.usage, another_usage_two_image.usage], result.pluck(:type)
      end

      test "returns an empty object if there are no non-embeddable usages in the schema" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
          "settings" => {
            "images" => {
              "enabled" => true,
              "usages" => {
                "govspeak_embed" => {
                  "kinds" => %w[default],
                  "multiple" => true,
                },
              },
            },
          },
        }))
        page = create(:standard_edition, images: [create(:image, usage: "govspeak_embed")])
        result = PayloadBuilder::Images.for(page)

        assert_equal({}, result)
      end
    end
  end
end
