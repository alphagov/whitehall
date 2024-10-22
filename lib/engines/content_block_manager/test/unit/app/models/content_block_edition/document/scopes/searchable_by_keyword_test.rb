require "test_helper"

class ContentBlockManager::SearchableByKeywordTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_keyword" do
    test "should find documents with title containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address, title: "klingons and such")
      _edition_with_first_keyword = create(:content_block_edition,
                                           :email_address,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" })
      document_without_first_keyword = create(:content_block_document, :email_address, title: "this document is about muppets")
      _edition_without_first_keyword = create(:content_block_edition, :email_address, document: document_without_first_keyword)
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("klingons")
    end

    test "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:content_block_document, :email_address, title: "klingons and such")
      _edition_with_first_keyword = create(:content_block_edition,
                                           :email_address,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" })
      _document_without_first_keyword = create(:content_block_document, :email_address, title: "muppets and such")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("such klingons")
    end

    test "should find documents with latest edition's details containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address, title: "example title")
      _edition_with_first_keyword = create(:content_block_edition,
                                           document: document_with_first_keyword,
                                           details: { "foo" => "Foo text", "bar" => "Bar text" })
      document_without_first_keyword = create(:content_block_document, :email_address, title: "this document is about muppets")
      _edition_without_first_keyword = create(:content_block_edition,
                                              document: document_without_first_keyword,
                                              details: { "something" => "something" })
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("foo bar")
    end

    test "should find documents with details or title containing keyword" do
      document_with_keyword_in_details = create(:content_block_document, :email_address, title: "example title")
      _edition_with_keyword = create(:content_block_edition,
                                     document: document_with_keyword_in_details,
                                     details: { "foo" => "Foo text", "bar" => "Bar text" })
      document_with_keyword_in_title = create(:content_block_document, :email_address, title: "this document is about bar foo")
      _edition_without_keyword = create(:content_block_edition,
                                        document: document_with_keyword_in_title,
                                        details: { "something" => "something" })
      assert_equal [document_with_keyword_in_details, document_with_keyword_in_title], ContentBlockManager::ContentBlock::Document.with_keyword("foo bar")
    end
  end
end
