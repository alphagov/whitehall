require "test_helper"

class ContentBlockManager::SearchableByKeywordTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_keyword" do
    test "should find documents with title containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address)
      _edition_with_first_keyword = create(:content_block_edition,
                                           :email_address,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" },
                                           title: "klingons and such")
      document_without_first_keyword = create(:content_block_document, :email_address)
      _edition_without_first_keyword = create(:content_block_edition, :email_address, document: document_without_first_keyword,
                                                                                      title: "this document is about muppets")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("klingons")
    end

    test "should find documents with title containing keywords not in order" do
      document_with_first_keyword = create(:content_block_document, :email_address)
      _edition_with_first_keyword = create(:content_block_edition,
                                           :email_address,
                                           document: document_with_first_keyword,
                                           details: { "email_address" => "hello@hello.com" },
                                           title: "klingons and such")
      _document_without_first_keyword = create(:content_block_document, :email_address)
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("such klingons")
    end

    test "should find documents with latest edition's details containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address)
      _edition_with_first_keyword = create(:content_block_edition,
                                           document: document_with_first_keyword,
                                           details: { "foo" => "Foo text", "bar" => "Bar text" },
                                           title: "example title")
      document_without_first_keyword = create(:content_block_document, :email_address)
      _edition_without_first_keyword = create(:content_block_edition,
                                              document: document_without_first_keyword,
                                              details: { "something" => "something" },
                                              title: "this document is about muppets")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("foo bar")
    end

    test "should find documents with instructions to publishers containing keyword" do
      document_with_first_keyword = create(:content_block_document, :email_address)
      _edition_with_first_keyword = create(:content_block_edition,
                                           document: document_with_first_keyword,
                                           instructions_to_publishers: "foo",
                                           title: "example title")
      document_without_first_keyword = create(:content_block_document, :email_address)
      _edition_without_first_keyword = create(:content_block_edition,
                                              document: document_without_first_keyword,
                                              instructions_to_publishers: "bar",
                                              title: "this document is about muppets")
      assert_equal [document_with_first_keyword], ContentBlockManager::ContentBlock::Document.with_keyword("foo")
    end

    test "should find documents with details or title containing keyword" do
      document_with_keyword_in_details = create(:content_block_document, :email_address)
      _edition_with_keyword = create(:content_block_edition,
                                     document: document_with_keyword_in_details,
                                     details: { "foo" => "Foo text", "bar" => "Bar text" },
                                     title: "example title")
      document_with_keyword_in_title = create(:content_block_document, :email_address)
      _edition_without_keyword = create(:content_block_edition,
                                        document: document_with_keyword_in_title,
                                        details: { "something" => "something" },
                                        title: "this document is about bar foo")
      assert_equal [document_with_keyword_in_details, document_with_keyword_in_title], ContentBlockManager::ContentBlock::Document.with_keyword("foo bar")
    end
  end
end
