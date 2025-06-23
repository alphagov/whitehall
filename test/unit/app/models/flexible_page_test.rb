require "test_helper"

class FlexiblePageTest < ActiveSupport::TestCase
  test "does not require some of the standard edition fields" do
    page = FlexiblePage.new
    assert_not page.summary_required?
    assert_not page.body_required?
    assert_not page.can_set_previously_published?
    assert_not page.previously_published
  end

  test "it allows images if the flexible page type settings permit them" do
    test_types = {
      "test_type_with_images" => {
        "key" => "test_type_with_images",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "images_enabled" => true,
        },
      },
      "test_type_without_images" => {
        "key" => "test_type_without_images",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {
          "images_enabled" => false,
        },
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page_with_images = FlexiblePage.new(flexible_page_type: "test_type_with_images")
    page_without_images = FlexiblePage.new(flexible_page_type: "test_type_without_images")
    assert page_with_images.allows_image_attachments?
    assert_not page_without_images.allows_image_attachments?
  end

  test "it is invalid if the flexible page content does not conform to the flexible page type schema" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {},
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page = FlexiblePage.new
    page.title = "Test Page"
    page.flexible_page_type = "test_type"
    page.flexible_page_content = {}
    page.creator = User.new
    assert page.invalid?
  end

  test "it is able to validate govspeak formatted attributes" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
              "format" => "govspeak",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {},
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page = FlexiblePage.new
    page.title = "Test Page"
    page.flexible_page_type = "test_type"
    page.flexible_page_content = {
      "test_attribute" => "<script>alert('You've been pwned!')</script>'",
    }
    page.creator = User.new
    assert page.invalid?
  end

  test "it is able to validate that image select formatted attributes are numeric strings" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
              "format" => "image_select",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {},
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page = FlexiblePage.new
    page.title = "Test Page"
    page.flexible_page_type = "test_type"
    page.flexible_page_content = {
      "test_attribute" => "invalid image ID",
    }
    page.creator = User.new
    assert page.invalid?
  end

  test "it allows empty values for image select formatted attributes" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "type" => "string",
              "format" => "image_select",
            },
          },
          "required" => %w[test_attribute],
        },
        "settings" => {},
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page = FlexiblePage.new
    page.title = "Test Page"
    page.flexible_page_type = "test_type"
    page.flexible_page_content = {
      "test_attribute" => "",
    }
    page.creator = User.new
    assert page.valid?
  end
end
