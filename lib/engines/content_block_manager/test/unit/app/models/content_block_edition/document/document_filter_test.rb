require "test_helper"

class ContentBlockManager::DocumentFilterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "documents" do
    describe "when no filters are given" do
      it "returns live documents" do
        document_scope_mock = mock
        ContentBlockManager::ContentBlock::Document.expects(:live).returns(document_scope_mock)
        document_scope_mock.expects(:with_keyword).never
        document_scope_mock.expects(:where).never
        document_scope_mock.expects(:with_lead_organisation).never

        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({}).documents
      end
    end

    describe "when a keyword filter is given" do
      it "returns live documents with keyword" do
        document_scope_mock = mock
        ContentBlockManager::ContentBlock::Document.expects(:live).returns(document_scope_mock)
        document_scope_mock.expects(:with_keyword).with("ministry of example").returns([])
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ keyword: "ministry of example" }).documents
      end
    end

    describe "when a block type is given" do
      it "returns live documents of the type given" do
        document_scope_mock = mock
        ContentBlockManager::ContentBlock::Document.expects(:live).returns(document_scope_mock)
        document_scope_mock.expects(:where).with(block_type: %w[email_address]).returns([])
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ block_type: %w[email_address] }).documents
      end
    end

    describe "when a lead organisation id is given" do
      it "returns live documents with lead org given" do
        document_scope_mock = mock
        ContentBlockManager::ContentBlock::Document.expects(:live).returns(document_scope_mock)
        document_scope_mock.expects(:with_lead_organisation).with("123").returns([])
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new({ lead_organisation: "123" }).documents
      end
    end

    describe "when block types, keyword and organisation is given" do
      it "returns live documents with the filters given" do
        document_scope_mock = mock
        ContentBlockManager::ContentBlock::Document.expects(:live).returns(document_scope_mock)
        document_scope_mock.expects(:with_keyword).with("ministry of example").returns(document_scope_mock)
        document_scope_mock.expects(:where).with(block_type: %w[email_address]).returns(document_scope_mock)
        document_scope_mock.expects(:with_lead_organisation).with("123").returns([])
        ContentBlockManager::ContentBlock::Document::DocumentFilter.new(
          { block_type: %w[email_address], keyword: "ministry of example", lead_organisation: "123" },
        ).documents
      end
    end
  end
end
