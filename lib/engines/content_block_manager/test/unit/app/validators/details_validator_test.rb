require "test_helper"

class ContentBlockManager::DetailsValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) do
    {
      "type" => "object",
      "required" => %w[foo bar],
      "additionalProperties" => false,
      "properties" => {
        "foo" => {
          "type" => "string",
          "format" => "email",
        },
        "bar" => {
          "type" => "string",
          "format" => "date",
        },
        "things" => {
          "type" => "object",
          "patternProperties" => {
            "^[a-z0-9]+(?:-[a-z0-9]+)*$" => {
              "type" => "object",
              "required" => %w[my_string],
              "properties" => {
                "my_string" => {
                  "type" => "string",
                },
                "something_else" => {
                  "type" => "string",
                  "format" => "email",
                },
              },
            },
          },
        },
      },
    }
  end

  let(:schema) { build(:content_block_schema, body:) }

  test "it validates the presence of fields" do
    content_block_edition = build(
      :content_block_edition,
      :pension,
      details: {
        foo: "",
        bar: "",
      },
      schema:,
    )

    assert_equal content_block_edition.valid?, false
    errors = content_block_edition.errors

    assert_error errors:, key: :details_foo, type: "blank", attribute: "Foo"
    assert_error errors:, key: :details_bar, type: "blank", attribute: "Bar"
  end

  test "it validates the format of fields" do
    content_block_edition = build(
      :content_block_edition,
      :pension,
      details: {
        foo: "dddd",
        bar: "ffff",
      },
      schema:,
    )

    assert_equal content_block_edition.valid?, false
    errors = content_block_edition.errors

    assert_equal errors.count, 2
    assert_error errors:, key: :details_foo, type: "invalid", attribute: "Foo"
    assert_error errors:, key: :details_bar, type: "invalid", attribute: "Bar"
  end

  it "validates the presence of nested fields in nested objects" do
    content_block_edition = build(
      :content_block_edition,
      :pension,
      details: {
        foo: "foo@example.com",
        bar: "2022-01-01",
        things: {
          "something-else": {
            my_string: "",
            something_else: "",
          },
        },
      },
      schema:,
    )

    assert_equal content_block_edition.valid?, false

    errors = content_block_edition.errors

    assert_equal errors.count, 1
    assert_error errors:, key: :details_things_my_string, type: "blank", attribute: "My string"
  end

  it "validates the format of nested fields in nested objects" do
    content_block_edition = build(
      :content_block_edition,
      :pension,
      details: {
        foo: "foo@example.com",
        bar: "2022-01-01",
        things: {
          "something-else": {
            my_string: "something",
            something_else: "Not an email",
          },
        },
      },
      schema:,
    )

    assert_equal content_block_edition.valid?, false

    errors = content_block_edition.errors

    assert_error errors:, key: :details_things_something_else, type: "invalid", attribute: "Something else"
  end

  describe "validating against a regular expression" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[foo],
        "additionalProperties" => false,
        "properties" => {
          "foo" => {
            "type" => "string",
            "pattern" => "£[0-9]+\\.[0-9]+",
          },
        },
      }
    end

    it "returns an error if the pattern is incorrect" do
      content_block_edition = build(
        :content_block_edition,
        :pension,
        details: {
          foo: "1234",
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      errors = content_block_edition.errors
      assert_error errors:, key: :details_foo, type: "invalid", attribute: "Foo"
    end
  end

  describe "validating against arrays" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[foo bar],
        "additionalProperties" => false,
        "properties" => {
          "things" => {
            "type" => "object",
            "patternProperties" => {
              "^[a-z0-9]+(?:-[a-z0-9]+)*$" => {
                "type" => "object",
                "properties" => {
                  "array_of_objects" => {
                    "type" => "array",
                    "items" => {
                      "type" => "object",
                      "required" => %w[foo],
                      "properties" => {
                        "foo" => {
                          "type" => "string",
                          "pattern" => "valid",
                        },
                        "bar" => {
                          "type" => "string",
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    it "returns an error if a required item is missing in an array of objects" do
      content_block_edition = build(
        :content_block_edition,
        :pension,
        details: {
          foo: "foo@example.com",
          bar: "2022-01-01",
          things: {
            "something-else": {
              array_of_objects: [
                {
                  foo: "valid",
                  bar: "something",
                },
                {
                  foo: "",
                  bar: "something",
                },
              ],
            },
          },
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      errors = content_block_edition.errors
      assert_error errors:, key: :details_things_array_of_objects_1_foo, type: "blank", attribute: "Foo"
    end

    it "returns an error if an item is invalid in an array of objects" do
      content_block_edition = build(
        :content_block_edition,
        :pension,
        details: {
          foo: "foo@example.com",
          bar: "2022-01-01",
          things: {
            "something-else": {
              array_of_objects: [
                {
                  foo: "not correct",
                  bar: "something",
                },
                {
                  foo: "",
                  bar: "something",
                },
              ],
            },
          },
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      errors = content_block_edition.errors
      assert_error errors:, key: :details_things_array_of_objects_0_foo, type: "invalid", attribute: "Foo"
    end
  end

  describe "#key_with_optional_prefix" do
    let(:validator) { ContentBlockManager::DetailsValidator.new }

    it "returns the key when an error does not have a data_pointer" do
      assert_equal validator.key_with_optional_prefix({}, "my_key"), "my_key"
    end

    it "returns the key without a reference to the embedded object when a data_pointer is present" do
      error = { "data_pointer" => "/foo/something" }
      assert_equal validator.key_with_optional_prefix(error, "my_key"), "foo_my_key"
    end

    it "returns the key without a reference to the embedded object when a data_pointer is present and nested" do
      error = { "data_pointer" => "/foo/something/field" }
      assert_equal validator.key_with_optional_prefix(error, "my_key"), "foo_field_my_key"
    end
  end

  def assert_error(errors:, key:, type:, attribute:)
    assert_equal errors[key], [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.#{type}", attribute:)]
  end
end
