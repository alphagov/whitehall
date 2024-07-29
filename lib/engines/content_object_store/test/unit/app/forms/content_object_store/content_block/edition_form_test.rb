require "test_helper"

class ContentObjectStore::ContentBlock::EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentObjectStore::Engine.routes.url_helpers

  describe "when initialized for a new object" do
    test "it initializes with the correct attributes from the schema" do
      content_block_edition = build(:content_block_edition, :email_address)
      schema = build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } })

      result = ContentObjectStore::ContentBlock::EditionForm::Create.new(
        content_block_edition:,
        schema:,
      )
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
      assert_equal content_object_store_content_block_documents_path, result.back_path
    end
  end

  describe "when initialized for an existing object" do
    test "it initializes with the correct attributes from the object" do
      content_block_edition = create(:content_block_edition, :email_address)
      schema = build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } })
      result = ContentObjectStore::ContentBlock::EditionForm::Update.new(
        content_block_edition:,
        schema:,
      )

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal content_block_edition.details, result.attributes
      assert_equal content_object_store_content_block_document_path(content_block_edition.document), result.back_path
    end
  end
end
