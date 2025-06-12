require "test_helper"

class PublishingApi::FlexiblePagePresenterTest < ActiveSupport::TestCase
  test "it applies the flexible page content layout" do
    test_types = {
      "test_type" => {
        "key" => "test_type",
        "schema" => {
          "$schema": "https://json-schema.org/draft/2020-12/schema",
          "$id": "https://www.gov.uk/schemas/test_type/v1",
          "title": "Test type",
          "type": "object",
          "properties" => {
            "test_attribute_one" => {
              "title" => "Test attribute one",
              "type" => "string",
            },
            "test_attribute_two" => {
              "title" => "Test attribute two",
              "type" => "string"
            },
            "test_object_attribute" => {
              "title" => "Test Object Attribute",
              "type" => "object",
              "properties" => {
                "test_object_attribute_one" => {
                  "title" => "Test object attribute one",
                  "type" => "string",
                },
                "test_object_attribute_two" => {
                  "title" => "Test object attribute two",
                  "type" => "string",
                }
              },
            },
          },
        },
        "layout" => {
          "rows" => [
            {
              "columns" => [
                {
                  "width" => "one-half",
                  "blocks" => [
                    { "schema_property_key" => "test_attribute_one" },
                  ]
                },
                {
                  "width" => "one-half",
                  "blocks" => [
                    {
                      "schema_property_key" => "test_attribute_two"
                    },
                    {
                      "schema_property_key" => "test_object_attribute"
                    },
                  ]
                }
              ]
            }
          ],
        },
      },
    }
    FlexiblePageType.setup_test_types(test_types)
    page = FlexiblePage.new
    document = Document.new
    document.slug = "test-flexible-page"
    page.document = document
    page.title = "Test Flexible Page"
    page.flexible_page_type = "test_type"
    page.flexible_page_content = {
      "test_attribute_one" => "foo",
      "test_attribute_two" => "bar",
      "test_object_attribute" => {
        "test_object_attribute_one" => "baz",
        "test_object_attribute_two" => "qux",
      },
    }

    presenter = PublishingApi::FlexiblePagePresenter.new(page)
    expected_flexible_page_content = {
      rows: [
        {
          columns: [
            {
              width: "one-half",
              blocks: [
                {
                  type: "string",
                  value: "foo",
                }
              ]
            },
            {
              width: "one-half",
              blocks: [
                {
                  type: "string",
                  value: "bar",
                },
                {
                  type: "object",
                  value: {
                    "test_object_attribute_one" => "baz",
                    "test_object_attribute_two" => "qux",
                  }
                }
              ],
            },
          ],
        },
      ],
    }

    assert_equal expected_flexible_page_content, presenter.content[:details][:flexible_page_content]
  end
end



