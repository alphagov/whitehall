require "test_helper"

class BlockContentTest < ActiveSupport::TestCase
  setup do
    @schema = {
      "title" => "Test document type",
      "properties" => {
        "test_attribute" => {
          "title" => "Test attribute",
          "type" => "string",
          "format" => "govspeak",
        },
        "test_number_attribute" => {
          "title" => "Test attribute",
          "type" => "integer",
        },
      },
    }
  end

  test "raises exception when encountering a validation rule with no definition" do
    schema = @schema.merge({
      "validations" => {
        "made_up_validation_rule" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    error = assert_raises(ArgumentError) do
      page.attributes = { "test_attribute" => "" }
      page.valid?
    end
    assert_equal "undefined validator type made_up_validation_rule", error.message
  end

  test "casts number attributes to a number for storage" do
    page = StandardEdition::BlockContent.new(@schema)

    page.attributes = { "test_number_attribute" => "1" }
    assert_equal(1, page.test_number_attribute)
  end

  test "casts number attributes to nil for storage if the input value is an empty string" do
    page = StandardEdition::BlockContent.new(@schema)

    page.attributes = { "test_number_attribute" => "" }
    assert_nil page.test_number_attribute
  end

  test "maps 'presence' validation to ActiveModel::Validations::PresenceValidator" do
    schema = @schema.merge({
      "validations" => {
        "presence" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :blank).empty?
  end

  test "maps 'length' validation to ActiveModel::Validations::LengthValidator" do
    schema = @schema.merge({
      "validations" => {
        "length" => {
          "attributes" => %w[test_attribute],
          "maximum" => 5,
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "exceeds max length" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :too_long, count: 5).empty?
  end

  test "maps 'safe_html' validation to SafeHtmlValidator" do
    Whitehall.stubs(:skip_safe_html_validation).returns(false)

    schema = @schema.merge({
      "validations" => {
        "safe_html" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "<script>alert('MALICIOUS')</script>" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :unsafe_html).empty?
  end

  test "maps 'no_footnotes_allowed' validation to NoFootnotesInGovspeakValidator" do
    schema = @schema.merge({
      "validations" => {
        "no_footnotes_allowed" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "[^1]\n\n[^1]: Footnote text" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :no_footnotes_allowed).empty?
  end

  test "maps 'valid_internal_path_links' validation to InternalPathLinksValidator" do
    schema = @schema.merge({
      "validations" => {
        "valid_internal_path_links" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "[Invalid admin link](//admin/editions)" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :invalid_path_link).empty?
  end

  test "maps 'embedded_contacts_exist' validation to EmbeddedContactsExistValidator" do
    schema = @schema.merge({
      "validations" => {
        "embedded_contacts_exist" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    page = StandardEdition::BlockContent.new(schema)

    page.attributes = { "test_attribute" => "[Contact:999999999]" }
    assert_not page.valid?
    assert_not page.errors.where("test_attribute", :embedded_contact_invalid).empty?
  end
end
