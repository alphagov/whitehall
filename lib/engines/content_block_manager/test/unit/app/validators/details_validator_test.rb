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
      :email_address,
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
      :email_address,
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
      :email_address,
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
      :email_address,
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

  def assert_error(errors:, key:, type:, attribute:)
    assert_equal errors[key], [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.#{type}", attribute:)]
  end
end
