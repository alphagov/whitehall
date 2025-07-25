require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::BslGuidanceComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :contact) }
  let(:schema) { build(:content_block_schema) }

  let(:body) do
    {
      "type" => "object",
      "properties" =>
        { "bsl_guidance" =>
            { "type" => "object",
              "properties" =>
                { "value" => { "type" => "string", "default" => "DEFAULT VALUE" },
                  "show" => { "type" => "boolean", "default" => false } } } },
    }
  end

  before do
    schema.stubs(:body).returns(body)
  end

  let(:field) do
    ContentBlockManager::ContentBlock::Schema::Field.new(
      "bsl_guidance",
      schema,
    )
  end

  let(:field_value) do
    { "show" => nil,
      "value" => nil }
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::BslGuidanceComponent.new(
      content_block_edition:,
      field: field,
      value: field_value,
    )
  end

  describe "BSL Guidance component" do
    describe "'show' nested field" do
      it "shows a checkbox to toggle 'Show BSL Guidance' option" do
        render_inline(component)

        assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
          component.assert_selector("label", text: I18n.t("content_block_edition.details.labels.telephones.bsl_guidance.show"))
        end
      end

      context "when the 'show' value is true" do
        let(:field_value) do
          { "value" => nil,
            "show" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show' value is false" do
        let(:field_value) do
          { "value" => nil,
            "show" => false }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end
    end

    describe "'value' nested field" do
      context "when a value is set for the 'value'" do
        let(:field_value) do
          { "show" => nil,
            "value" => "CUSTOM VALUE" }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='content_block/edition[details][bsl_guidance][value]']",
              text: "CUSTOM VALUE",
            )
          end
        end
      end

      context "when a value is NOT set for the 'value'" do
        let(:field_value) do
          { "show" => nil,
            "value" => nil }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='content_block/edition[details][bsl_guidance][value]']",
              text: "DEFAULT VALUE",
            )
          end
        end
      end
    end
  end
end
