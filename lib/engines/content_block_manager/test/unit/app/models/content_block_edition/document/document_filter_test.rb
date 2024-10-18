require "test_helper"

class ContentBlockManager::DocumentFilterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "documents" do
    describe "when no filters are given" do
      it "returns live documents" do
        live_documents = create_list(:content_block_document, 2, :email_address)
        live_documents.each { |doc| create(:content_block_edition, :email_address, document: doc) }
        _not_live_documents = create_list(:content_block_document, 2, :email_address)
        assert_equal live_documents, ContentBlockManager::ContentBlock::Document::DocumentFilter.new({}).documents
      end
    end

    describe "when a title filter is given" do
      it "returns live documents with keyword in title" do
        live_documents_with_title = create_list(:content_block_document, 2, :email_address, title: "ministry of example")
        live_documents_with_title.each { |doc| create(:content_block_edition, :email_address, document: doc) }
        _not_live_documents = create_list(:content_block_document, 2, :email_address)
        live_documents_without_keyword = create_list(:content_block_document, 2, :email_address, title: "another ministry")
        live_documents_without_keyword.each { |doc| create(:content_block_edition, :email_address, document: doc) }
        assert_equal live_documents_with_title, ContentBlockManager::ContentBlock::Document::DocumentFilter
                                                    .new({ title: "ministry of example" }).documents
      end
    end
  end
end
