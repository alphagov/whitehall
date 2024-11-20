require "test_helper"

class ContentBlockManager::FindAndReplaceEmbedCodesServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "finds and replaces embed codes" do
    document_1 = create(:content_block_document, :email_address)
    edition_1 = create(:content_block_edition, :email_address, state: "published", document: document_1)
    document_1.latest_edition = edition_1
    document_1.save!

    document_2 = create(:content_block_document, :email_address)
    edition_2 = create(:content_block_edition, :email_address, state: "published", document: document_2)
    document_2.latest_edition = edition_2
    document_2.save!

    html = """
      <p>Hello there</p>
      <p>#{edition_2.document.embed_code}</p>
      <p>#{edition_1.document.embed_code}</p>
    """

    expected = """
      <p>Hello there</p>
      <p>#{edition_2.render}</p>
      <p>#{edition_1.render}</p>
    """

    result = ContentBlockManager::FindAndReplaceEmbedCodesService.call(html)

    assert_equal result, expected
  end

  it "ignores blocks that aren't present in the database" do
    edition = build(:content_block_edition, :email_address)

    html = edition.document.embed_code

    result = ContentBlockManager::FindAndReplaceEmbedCodesService.call(html)
    assert_equal result, html
  end

  it "ignores blocks that don't have a live version" do
    edition = create(:content_block_edition, :email_address, state: "draft")

    html = edition.document.embed_code

    result = ContentBlockManager::FindAndReplaceEmbedCodesService.call(html)
    assert_equal result, html
  end
end
