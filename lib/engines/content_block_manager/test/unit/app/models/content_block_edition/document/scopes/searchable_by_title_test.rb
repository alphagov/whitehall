require "test_helper"

class ContentBlockManager::SearchableByTitleTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_title" do
    test "should find documents with title containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address, title: "klingons and such")
      _edition_with_first_keyword = create(:content_block_edition, :email_address, document: document_with_first_keyword)
      _document_without_first_keyword = create(:content_block_document, :email_address, title: "this document is about muppets")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_title("klingons")
    end

    test "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:content_block_document, :email_address, title: "klingons and such")
      _edition_with_first_keyword = create(:content_block_edition, :email_address, document: document_with_first_keyword)
      _document_without_first_keyword = create(:content_block_document, :email_address, title: "muppets and such")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_title("such klingons")
    end
  end
end
