require "test_helper"

class ContentBlockManager::ContentBlock::GovSpeakHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::ContentBlock::GovspeakHelper

  describe "render_govspeak_if_enabled_for_field(object_key:, field_name:, value:)" do
    let(:subschema) { stub(:subschema) }

    context "when the field has been declared 'govspeak_enabled' in the schema" do
      before do
        subschema.stubs(:govspeak_enabled?).returns(true)
      end

      it "renders the given value into HTML using the GovSpeak gem" do
        html = render_govspeak_if_enabled_for_field(object_key: "nested_obj", field_name: "field_1", value: "value")
        assert_equal(
          "<p>value</p>",
          html.strip,
        )
      end
    end

    context "when the field has NOT been declared 'govspeak_enabled' in the schema" do
      before do
        subschema.stubs(:govspeak_enabled?).returns(false)
      end

      it "renders the given value without converting to HTML" do
        html = render_govspeak_if_enabled_for_field(object_key: "nested_obj", field_name: "field_1", value: "value")
        assert_equal(
          "value",
          html.strip,
        )
      end
    end
  end
end
