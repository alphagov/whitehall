require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::GovspeakEnabledTextareaComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  COMPONENT_CLASS = ".app-c-content-block-manager-govspeak-enabled-textarea-component".freeze

  let(:content_block_edition) { build(:content_block_edition, :contact) }

  let(:properties) do
    {
      "video_relay_service" => {
        "x-govspeak_enabled" => %w[prefix],
      },
    }
  end

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => properties,
        },
      },
    }
  end

  let(:subschema) do
    ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new(
      "telephones",
      body,
      "parent_schema_id",
    )
  end

  let(:field) do
    ContentBlockManager::ContentBlock::Schema::Field::NestedField.new(
      name: "prefix",
      format: "string",
      enum_values: nil,
      default_value: "**Default** prefix: 18000 then",
    )
  end

  let(:field_value) do
    {
      "prefix" => nil,
    }
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Details::Fields::GovspeakEnabledTextareaComponent.new(
      content_block_edition: content_block_edition,
      field: field,
      value: field_value,
      nested_object_key: "video_relay_service",
      subschema: subschema,
    )
  end

  before do
    I18n.expects(:t).with(
      "content_block_edition.details.labels.telephones.video_relay_service.prefix",
      default: "Prefix",
    ).returns("Translated label")
  end

  describe "GovspeakEnabledTextareaComponent" do
    it "wraps component in an element with an ID describing path to field" do
      render_inline component

      assert_selector(COMPONENT_CLASS) do |component|
        wraps_whole_textarea_in_element_with_id_describing_path_to_field(component)
      end
    end

    it "includes a translated _label_" do
      render_inline component

      assert_selector(COMPONENT_CLASS) do |component|
        displays_label_using_translation_system(component)
      end
    end

    it "includes a _name_ attribute representing nested field location" do
      render_inline component

      assert_selector(COMPONENT_CLASS) do |component|
        sets_name_attribute_on_textarea_describing_nested_path_to_field(component)
      end
    end

    describe "default value" do
      context "when there is NO value set for the textarea" do
        let(:field_value) do
          { "prefix" => nil }
        end

        it "supplies the default value defined in the schema" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            shows_default_value_in_textarea(component)
          end
        end
      end

      context "when there IS a value set for the textarea" do
        let(:field_value) do
          { "prefix" => "Field value *set*" }
        end

        it "displays that value" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            shows_set_value_in_textarea(component, "Field value *set*")
          end
        end
      end

      context "when there is an error on the field" do
        before do
          content_block_edition.errors.add(
            :details_telephones_video_relay_service_prefix,
            "blank",
          )

          I18n.expects(:t).with(
            "activerecord.errors.models.content_block_manager/content_block/edition" \
              ".attributes.details_telephones_video_relay_service_prefix.format".to_sym,
            has_entry(message: "blank"),
          ).returns("Prefix must be present")
        end

        it "adds an error class to the form group to highlight the area needing attention" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            component.assert_selector(".govuk-form-group.govuk-form-group--error")
          end
        end

        it "adds an error message to clarify the error and remedial action required" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            component.assert_selector(
              ".govuk-error-message",
              text: "Prefix must be present",
            )
          end
        end
      end
    end

    describe "'Govspeak supported' indicator" do
      context "when the field IS declared 'govspeak-enabled' in the subschema" do
        let(:properties) do
          {
            "video_relay_service" => {
              "x-govspeak_enabled" => %w[prefix],
            },
          }
        end

        it "displays a 'Govspeak supported' hint" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            displays_indication_that_govspeak_is_supported(component)
          end
        end

        describe "hint ID mapping to textarea 'aria-describedby'" do
          let(:expected_hint_id_to_aria_mapping) do
            "content_block_manager_content_block_edition_details_" \
              "telephones_video_relay_service_prefix-" \
              "hint"
          end

          it "includes an 'aria-describedby' attribute on the textarea, to match the label hint's ID" do
            render_inline component

            assert_selector(COMPONENT_CLASS) do |component|
              component.assert_selector(
                "textarea[aria-describedby='#{expected_hint_id_to_aria_mapping}']",
              )
            end
          end

          it "includes an ID on the label hint div, matching the 'aria-describedby' on the textarea" do
            render_inline component

            assert_selector(COMPONENT_CLASS) do |component|
              component.assert_selector(
                "div.govuk-hint[id='#{expected_hint_id_to_aria_mapping}']",
              )
            end
          end
        end
      end

      context "when the field is NOT declared 'govspeak-enabled in the subschema" do
        let(:properties) do
          {
            "video_relay_service" => {
              "x-govspeak_enabled" => [],
            },
          }
        end

        it "does NOT display the 'Govspeak supported' hint" do
          render_inline component

          assert_selector(COMPONENT_CLASS) do |component|
            displays_no_indication_that_govspeak_is_supported(component)
          end
        end
      end
    end
  end

  def wraps_whole_textarea_in_element_with_id_describing_path_to_field(component)
    expected_component_id =
      "content_block_manager_content_block_edition_details_telephones_video_relay_service_prefix"

    component.assert_selector(
      "div[id='#{expected_component_id}']",
    )
  end

  def displays_label_using_translation_system(component)
    component.assert_selector(
      "label",
      text: "Translated label",
    )
  end

  def sets_name_attribute_on_textarea_describing_nested_path_to_field(component)
    expected_name_attribute =
      "content_block/edition[details][telephones][video_relay_service][prefix]"

    component.assert_selector(
      "textarea[name='#{expected_name_attribute}']",
    )
  end

  def shows_default_value_in_textarea(component)
    component.assert_selector(
      "textarea",
      text: "**Default** prefix: 18000 then",
    )
  end

  def shows_set_value_in_textarea(component, value)
    component.assert_selector(
      "textarea",
      text: value,
    )
  end

  def displays_indication_that_govspeak_is_supported(component)
    component.assert_selector(
      ".govuk-hint",
      text: "Govspeak supported",
    )
  end

  def displays_no_indication_that_govspeak_is_supported(component)
    component.assert_no_selector(
      ".govuk-hint",
      text: "Govspeak supported",
    )
  end
end
