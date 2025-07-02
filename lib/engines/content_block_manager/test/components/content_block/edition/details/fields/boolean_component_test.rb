require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "email_address", is_required?: true) }

  it "should not check the checkbox if no value given" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.new(
        content_block_edition:,
        field:,
      ),
    )

    assert_selector "input[type=\"checkbox\"][value=\"true\"]"
    assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
  end

  it "should check checkbox if value given is 'true'" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.new(
        content_block_edition:,
        field:,
        value: "true",
      ),
    )

    assert_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
  end

  it "should not check the checkbox if value given is 'false'" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.new(
        content_block_edition:,
        field:,
        value: "false",
      ),
    )

    assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
  end
end
