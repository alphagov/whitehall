require "test_helper"

class ContentObjectStore::ContentBlockEditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "when initialized for a new object" do
    test "it initializes with the correct attributes from the schema" do
      content_block_edition = build(:content_block_edition, :email_address)
      schema = build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } })

      result = ContentObjectStore::ContentBlockEditionForm.new(
        content_block_edition:,
        schema:,
        attributes: schema.fields,
        back_path: "/back",
      )

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal schema.fields, result.attributes
      assert_equal "/back", result.back_path
    end
  end

  describe "when initialized for an existing object" do
    test "it initializes with the correct attributes from the object" do
      content_block_edition = create(:content_block_edition, :email_address)
      schema = build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } })
      result = ContentObjectStore::ContentBlockEditionForm.new(
        content_block_edition:,
        schema:,
        attributes: content_block_edition.details,
        back_path: "/back",
      )

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal content_block_edition.details, result.attributes
      assert_equal "/back", result.back_path
    end
  end
end
