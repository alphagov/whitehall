require "test_helper"
require "capybara/rails"

class ContentBlockEditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL

  describe "#index" do
    test "it returns all Content Block Editions" do
      content_block_document = create(:content_block_document)
      create(
        :content_block_edition,
        details: '"email_address":"example@example.com"',
        content_block_document_id: content_block_document.id,
      )
      visit "/government/admin/content-object-store/content-block-editions"
      assert_text '"email_address":"example@example.com"'
    end
  end

  describe "#new" do
    test "it shows a list of all the valid block types" do
      schemas = [
        ContentObjectStore::Schema.new("content_block_foo"),
        ContentObjectStore::Schema.new("content_block_bar"),
      ]

      ContentObjectStore::SchemaService.expects(:valid_schemas).returns(schemas)

      visit "/government/admin/content-object-store/content-block-editions/new"

      assert_text schemas[0].name
      assert_text schemas[1].name
    end
  end
end
