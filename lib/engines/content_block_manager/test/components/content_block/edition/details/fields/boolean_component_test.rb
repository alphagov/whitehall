require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:default_value) { nil }
  let(:field) { stub("field", name: "email_address", is_required?: true, default_value:) }

  before do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::BooleanComponent.new(
        content_block_edition:,
        field:,
        value: field_value,
      ),
    )
  end

  describe "when no value is given" do
    let(:field_value) { nil }

    it "should not check the checkbox" do
      assert_selector "input[type=\"checkbox\"][value=\"true\"]"
      assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end

    describe "when the default value is true" do
      let(:default_value) { "true" }

      it "should check the checkbox" do
        assert_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
      end
    end
  end

  describe "when the value given is 'true'" do
    let(:field_value) { "true" }

    it "should check the checkbox" do
      assert_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end

  describe "when the value given is 'false'" do
    let(:field_value) { "false" }

    it "should check the checkbox" do
      assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end
end
