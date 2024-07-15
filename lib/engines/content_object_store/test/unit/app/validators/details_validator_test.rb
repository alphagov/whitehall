require "test_helper"

class ContentObjectStore::DetailsValidatorTest < ActiveSupport::TestCase
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
    assert_equal content_block_edition.errors.messages[:details_foo], ["cannot be blank"]
    assert_equal content_block_edition.errors.messages[:details_bar], ["cannot be blank"]
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
    assert_equal content_block_edition.errors.messages[:details_foo], ["is an invalid Email"]
    assert_equal content_block_edition.errors.messages[:details_bar], ["is an invalid Date"]
  end
end
