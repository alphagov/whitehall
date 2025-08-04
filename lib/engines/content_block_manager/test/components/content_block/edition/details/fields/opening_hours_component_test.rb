require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :contact) }
  let(:schema) { build(:content_block_schema) }

  let(:body) do
    {
      "type" => "object",
      "properties" =>
        { "opening_hours" =>
            { "type" => "object",
              "properties" =>
                { "opening_hours" => { "type" => "string" },
                  "show_opening_hours" => { "type" => "boolean" } } } },
    }
  end

  before do
    schema.stubs(:body).returns(body)
  end

  let(:field) do
    ContentBlockManager::ContentBlock::Schema::Field.new(
      "opening_hours",
      schema,
    )
  end

  let(:field_value) do
    { "show_opening_hours" => nil,
      "opening_hours" => nil }
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::OpeningHoursComponent.new(
      content_block_edition:,
      field: field,
      value: field_value,
    )
  end

  describe "Opening hours component" do
    describe "show nested field" do
      it "shows a checkbox to toggle 'Show Opening Hours' option" do
        render_inline(component)

        assert_selector(".govuk-checkboxes") do |component|
          component.assert_selector("label", text: I18n.t("content_block_edition.details.labels.telephones.opening_hours.show_opening_hours"))
        end
      end

      context "when the 'show_opening_hours' value is true" do
        let(:field_value) do
          { "show_opening_hours" => true,
            "opening_hours" => nil }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".govuk-checkboxes") do |component|
            component.assert_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show_opening_hours' value is false" do
        let(:field_value) do
          { "show_opening_hours" => false,
            "opening_hours" => nil }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          assert_selector(".govuk-checkboxes") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end
    end

    describe "'opening_hours' nested field" do
      context "when a value is set for the 'opening_hours'" do
        let(:field_value) do
          { "show_opening_hours" => true,
            "opening_hours" => "CUSTOM VALUE" }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".govuk-checkboxes") do |component|
            component.assert_selector(
              "textarea" \
                "[name='content_block/edition[details][opening_hours][opening_hours]']",
              text: "CUSTOM VALUE",
            )
          end
        end
      end
    end
  end
end
