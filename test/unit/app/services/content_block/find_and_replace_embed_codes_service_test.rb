require "test_helper"

class ContentBlock::FindAndReplaceEmbedCodesServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "finds and replaces embed codes" do
    document_1 = create(:content_block_document, :pension, content_id_alias: "something")
    edition_1 = create(:content_block_edition, :pension, state: "published", document: document_1)
    document_1.latest_edition = edition_1
    document_1.save!

    document_2 = create(:content_block_document, :pension, content_id_alias: "something-else")
    edition_2 = create(:content_block_edition, :pension, state: "published", document: document_2)
    document_2.latest_edition = edition_2
    document_2.save!

    html = "
      <p>Hello there</p>
      <p>#{edition_2.document.embed_code(use_friendly_id: false)}</p>
      <p>#{edition_1.document.embed_code(use_friendly_id: true)}</p>
      <p>#{edition_2.document.embed_code(use_friendly_id: false)}</p>
    "

    expected = "
      <p>Hello there</p>
      <p>#{edition_2.render(edition_2.document.embed_code(use_friendly_id: false))}</p>
      <p>#{edition_1.render(edition_1.document.embed_code(use_friendly_id: true))}</p>
      <p>#{edition_2.render(edition_2.document.embed_code(use_friendly_id: false))}</p>
    "

    result = ContentBlock::FindAndReplaceEmbedCodesService.call(html)

    assert_equal result, expected
  end

  it "ignores blocks that aren't present in the database" do
    edition = build(:content_block_edition, :pension)

    html = edition.document.embed_code

    result = ContentBlock::FindAndReplaceEmbedCodesService.call(html)
    assert_equal result, html
  end

  it "ignores blocks that don't have a live version" do
    edition = create(:content_block_edition, :pension, state: "draft")

    html = edition.document.embed_code

    result = ContentBlock::FindAndReplaceEmbedCodesService.call(html)
    assert_equal result, html
  end
end
