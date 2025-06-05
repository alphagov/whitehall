require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::DefaultBlockComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:content_block_document) { build(:content_block_document, :pension) }

  let(:embed_code) { "EMBED_CODE" }
  let(:default_block_output) { "DEFAULT_BLOCK_OUTPUT" }

  before do
    content_block_document.stubs(:latest_edition).returns(content_block_edition)
    content_block_document.stubs(:embed_code).returns(embed_code)
    content_block_edition.stubs(:render).with(embed_code).returns(default_block_output)
  end

  it "renders the default block" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Show::DefaultBlockComponent.new(content_block_document:),
    )

    assert_selector ".govuk-summary-list__row[data-module=\"copy-embed-code\"][data-embed-code=\"#{embed_code}\"] .govuk-summary-list__value .govspeak", text: default_block_output
    assert_selector ".govuk-summary-list__value .app-c-content-block-manager-default-block__embed_code", text: embed_code
  end
end
