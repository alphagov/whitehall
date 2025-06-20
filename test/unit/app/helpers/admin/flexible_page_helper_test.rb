require "test_helper"

class Admin::FlexiblePageHelperTest < ActionView::TestCase
  test "flexible page helper outputs a fieldset for each object property" do
    schema = {
      "type" => "object",
      "properties" => {
        "one" => {
          "type" => "object",
          "title" => "One",
          "properties" => {
            "one_a" => {
              "type" => "string",
              "title" => "One A",
            },
          },
        },
        "two" => {
          "type" => "object",
          "title" => "Two",
          "properties" => {
            "two_a" => {
              "type" => "string",
              "title" => "Two A",
            },
          },
        },
      },
    }

    render inline: render_flexible_page_content_fields(schema, FlexiblePage.new)
    schema["properties"].values.each do |property|
      assert_dom "legend", text: property["title"]
    end
  end

  test "flexible page helper outputs the description for the field as hint text" do
    schema = {
      "type" => "object",
      "properties" => {
        "property_with_description" => {
          "type" => "string",
          "title" => "Property with description",
          "description" => "A property with a description",
        },
      },
    }

    render inline: render_flexible_page_content_fields(schema, FlexiblePage.new)
    assert_dom ".govuk-hint", text: schema["properties"]["property_with_description"]["description"]
  end

  test "flexible page helper sets the value of the input" do
    schema = {
      "type" => "object",
      "properties" => {
        "test" => {
          "type" => "object",
          "title" => "Test property",
          "properties" => {
            "test_one" => {
              "type" => "string",
              "title" => "test one",
            },
            "test_two" => {
              "type" => "string",
              "title" => "test two",
            },
          },
        },
      },
    }
    page = FlexiblePage.new
    page.flexible_page_content = {
      "test" => {
        "test_one" => "foo",
        "test_two" => "bar",
      },
    }
    render inline: render_flexible_page_content_fields(schema, page)
    assert_dom "input[name=\"edition[flexible_page_content][test][test_one]\"][value=\"foo\"]"
    assert_dom "input[name=\"edition[flexible_page_content][test][test_two]\"][value=\"bar\"]"
  end

  test "flexible page helper appends a required hint to the field label for required fields" do
    schema = {
      "type" => "object",
      "properties" => {
        "one" => {
          "type" => "string",
          "title" => "One",
        },
        "two" => {
          "type" => "string",
          "title" => "Two",
        },
      },
      "required" => %w[one],
    }

    render inline: render_flexible_page_content_fields(schema, FlexiblePage.new)
    assert_dom "label", text: "One (required)"
  end

  test "flexible page helper renders an input for a string property without govspeak format" do
    schema = {
      "type" => "object",
      "properties" => {
        "title" => {
          "type" => "string",
          "title" => "Title",
          "description" => "A regular string field",
        },
      },
    }

    render inline: render_flexible_page_content_fields(schema, FlexiblePage.new)
    assert_dom "input[name=\"edition[flexible_page_content][title]\"]"
    refute_dom "textarea[name=\"edition[flexible_page_content][title]\"]"
  end

  test "flexible page helper renders a textarea for a string property in the govspeak format" do
    schema = {
      "type" => "object",
      "properties" => {
        "body" => {
          "type" => "string",
          "title" => "Body",
          "description" => "The body content in govspeak format",
          "format" => "govspeak",
        },
      },
    }

    render inline: render_flexible_page_content_fields(schema, FlexiblePage.new)
    assert_dom "textarea[name=\"edition[flexible_page_content][body]\"]"
    refute_dom "input[name=\"edition[flexible_page_content][body]\"]"
  end
end
