require "test_helper"

class ContentBlockManager::ContentBlockEdition::HostContent::PreviewDetailsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension, details: { "email_address": "example@example.com" }) }
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

  context "when there are subschemas in the edition's details" do
    let(:content_block_edition) do
      build(:content_block_edition, :pension, details: {
        "description": "Basic state pension",
        "rates": {
          "rate1":
            { "title": "rate1", "amount": "£100.5", "frequency": "a week", "description": "" },
          "rate2":
              { "title": "rate2", "amount": "£11.1", "frequency": "a month", "description": "1111" },
        },
      })
    end
    it "returns a list of details for preview content" do
      render_inline(
        ContentBlockManager::ContentBlockEdition::HostContent::PreviewDetailsComponent.new(
          content_block_edition:,
          preview_content:,
        ),
      )

      assert_selector "li", count: 2
      assert_selector "li", text: "Description: Basic state pension"
      assert_selector "li", text: "Instances: 2"
    end
  end
end
