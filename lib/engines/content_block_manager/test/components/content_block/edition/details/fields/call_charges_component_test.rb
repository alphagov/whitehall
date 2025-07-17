require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::CallChargesComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :contact) }
  let(:schema) { build(:content_block_schema) }

  let(:body) do
    {
      "type" => "object",
      "properties" =>
        { "call_charges" =>
          { "type" => "object",
            "properties" =>
          { "label" => { "type" => "string", "default" => "Find out about call charges" },
            "call_charges_info_url" => { "type" => "string", "default" => "https://default.example.com" },
            "show_call_charges_info_url" => { "type" => "boolean", "default" => false } } } },
    }
  end

  before do
    schema.stubs(:body).returns(body)
  end

  let(:field) do
    ContentBlockManager::ContentBlock::Schema::Field.new(
      "call_charges",
      schema,
    )
  end

  let(:field_value) do
    { "call_charges_info_url" => nil,
      "show_call_charges_info_url" => nil }
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::CallChargesComponent.new(
      content_block_edition:,
      field: field,
      value: field_value,
    )
  end

  describe "Call Charges component" do
    describe "'show_call_charges_info_url' nested field" do
      it "shows a checkbox to toggle 'Show hyperlink' option" do
        render_inline(component)

        assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
          component.assert_selector("label", text: "Show hyperlink to 'Find out about call charges'")
        end
      end

      context "when the 'show_call_charges_info_url' value is true" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show_call_charges_info_url' value is false" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => false }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end
    end

    describe "'call_charges_info_url' nested field" do
      context "when a value is set for the 'call_charges_info_url'" do
        let(:field_value) do
          { "call_charges_info_url" => "https://custom.gov.uk/call-charges/more",
            "show_call_charges_info_url" => nil }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector(
              "input" \
              "[name='content_block/edition[details][call_charges][call_charges_info_url]']" \
              "[value='https://custom.gov.uk/call-charges/more']",
            )
          end
        end
      end

      context "when a value is NOT set for the 'call_charges_info_url'" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => nil }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector(
              "input" \
              "[name='content_block/edition[details][call_charges][call_charges_info_url]']" \
              "[value='https://default.example.com']",
            )
          end
        end
      end
    end
  end
end
