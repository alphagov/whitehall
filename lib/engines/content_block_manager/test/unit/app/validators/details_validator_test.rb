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
    assert_equal content_block_edition.errors.full_messages, [
      I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.blank", attribute: "Foo"),
      I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.blank", attribute: "Bar"),
    ]
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
    assert_equal content_block_edition.errors.full_messages, [
      I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: "Foo"),
      I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.invalid", attribute: "Bar"),
    ]
  end
end
