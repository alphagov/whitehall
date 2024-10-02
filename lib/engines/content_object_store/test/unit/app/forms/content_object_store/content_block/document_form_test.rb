require "test_helper"

class ContentObjectStore::ContentBlock::DocumentFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentObjectStore::Engine.routes.url_helpers

  let(:schema) { build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } }) }

  describe "when there is no edition provided" do
    let(:result) { ContentObjectStore::ContentBlock::DocumentForm.new(schema:) }

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "returns the correct paths" do
      assert_equal content_object_store_content_block_documents_path, result.back_path
      assert_equal content_object_store_content_block_documents_path(block_type: schema.block_type), result.url
    end

    it "initializes a new edition" do
      assert_kind_of ContentObjectStore::ContentBlock::Edition, result.content_block_edition
    end
  end

  describe "when an edition is provided" do
    let(:content_block_edition) { build(:content_block_edition, :email_address) }
    let(:result) { ContentObjectStore::ContentBlock::DocumentForm.new(schema:, content_block_edition:) }

    it "returns the provided edition" do
      assert_equal content_block_edition, result.content_block_edition
    end
  end
end
