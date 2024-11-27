require "test_helper"

class ContentBlockManager::ContentBlockEdition::HostContent::PreviewDetailsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :email_address, details: { "email_address": "example@example.com" }) }
  let(:preview_content) { build(:preview_content, instances_count: 2) }

  it "returns a list of details for preview content" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::HostContent::PreviewDetailsComponent.new(
        content_block_edition:,
        preview_content:,
      ),
    )

    assert_selector "li", count: 2
    assert_selector "li", text: "Email address: example@example.com"
    assert_selector "li", text: "Instances: 2"
  end
end
