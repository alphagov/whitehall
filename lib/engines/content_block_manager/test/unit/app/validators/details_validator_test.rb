require "test_helper"

class ContentBlockManager::DetailsValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:schema) { build(:content_block_schema, body:) }

  describe "with a non-nested schema" do
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

    it "validates the presence of fields" do
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
      assert_equal content_block_edition.errors.messages, {
        details_foo: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Foo")],
        details_bar: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Bar")],
      }
      assert_equal content_block_edition.errors.full_messages, [
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Foo"),
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Bar"),
      ]
    end

    it "validates the format of fields" do
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
      assert_equal content_block_edition.errors.messages, {
        details_foo: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Foo")],
        details_bar: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Bar")],
      }
      assert_equal content_block_edition.errors.full_messages, [
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Foo"),
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Bar"),
      ]
    end
  end

  describe "with a nested schema" do
    let(:body) do
      {
        "type" => "object",
        "required" => %w[my_array],
        "additionalProperties" => false,
        "properties" => {
          "my_array" => {
            "type" => "array",
            "items" => {
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
            },
          },
        },
      }
    end

    it "validates the presence of an array" do
      content_block_edition = build(
        :content_block_edition,
        :email_address,
        details: {
          my_array: [],
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      assert_equal content_block_edition.errors.full_messages, [
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "My array"),
      ]
    end

    it "validates the presence of fields in an array" do
      content_block_edition = build(
        :content_block_edition,
        :email_address,
        details: {
          my_array: [
            foo: "",
            bar: "",
          ],
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      assert_equal content_block_edition.errors.messages, {
        details_my_array_0_foo: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Foo")],
        details_my_array_0_bar: [I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Bar")],
      }
      assert_equal content_block_edition.errors.full_messages, [
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Foo"),
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.blank", attribute: "Bar"),
      ]
    end

    it "validates the format of fields in an array" do
      content_block_edition = build(
        :content_block_edition,
        :email_address,
        details: {
          my_array: [
            foo: "dddd",
            bar: "ffff",
          ],
        },
        schema:,
      )

      assert_equal content_block_edition.valid?, false
      assert_equal content_block_edition.errors.full_messages, [
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Foo"),
        I18n.t("#{ContentBlockManager::DetailsValidator::BASE_TRANSLATION_PATH}.invalid", attribute: "Bar"),
      ]
    end
  end
end
