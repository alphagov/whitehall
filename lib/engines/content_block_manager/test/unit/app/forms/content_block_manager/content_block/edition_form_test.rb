require "test_helper"

class ContentBlockManager::ContentBlock::EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::Engine.routes.url_helpers

  let(:schema) { build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:result) do
    ContentBlockManager::ContentBlock::EditionForm.for(
      content_block_edition:,
      schema:,
    )
  end

  describe "when initialized for an edition with an existing document and live edition" do
    let(:content_block_document) { build(:content_block_document, :email_address, id: 123, latest_edition_id: "5b271577-3d3d-475d-986a-246d8c4063a3") }
    let(:content_block_edition) { build(:content_block_edition, :email_address, document: content_block_document) }

    let(:result) do
      ContentBlockManager::ContentBlock::EditionForm.for(
        content_block_edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal "Edit Email address", result.title
    end

    it "sets the correct urls" do
      assert_equal content_block_manager_content_block_document_path(id: content_block_edition.document.id), result.back_path
      assert_equal content_block_manager_content_block_document_editions_path(document_id: content_block_edition.document.id), result.url
    end
  end

  describe "when initialized for an edition without an existing document" do
    let(:content_block_edition) { build(:content_block_edition, :email_address, document: nil) }

    let(:result) do
      ContentBlockManager::ContentBlock::EditionForm.for(
        content_block_edition:,
        schema:,
      )
    end

    it "initializes with the correct attributes from the schema" do
      expected_attributes = { "foo" => nil, "bar" => nil }

      assert_equal content_block_edition, result.content_block_edition
      assert_equal schema, result.schema
      assert_equal expected_attributes, result.attributes
    end

    it "sets the correct title" do
      assert_equal "Create email address", result.title
    end

    it "sets the correct urls" do
      assert_equal new_content_block_manager_content_block_document_path, result.back_path
      assert_equal content_block_manager_content_block_editions_path, result.url
    end
  end
end
