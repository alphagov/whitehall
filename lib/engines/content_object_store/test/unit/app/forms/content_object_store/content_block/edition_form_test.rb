require "test_helper"

class ContentObjectStore::ContentBlock::EditionFormTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentObjectStore::Engine.routes.url_helpers

  let(:content_block_edition) { create(:content_block_edition, :email_address) }
  let(:schema) { build(:content_block_schema, :email_address, body: { "properties" => { "foo" => "", "bar" => "" } }) }
  let(:result) do
    ContentObjectStore::ContentBlock::EditionForm.new(
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

  it "sets the correct urls" do
    assert_equal content_object_store_content_block_document_path(id: content_block_edition.document.id), result.back_path
    assert_equal content_object_store_content_block_document_editions_path(document_id: content_block_edition.document.id), result.url
  end
end
