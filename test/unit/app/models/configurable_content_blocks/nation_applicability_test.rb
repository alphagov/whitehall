require "test_helper"

class ConfigurableContentBlocks::NationApplicabilityRenderingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "title" => "Nation applicability",
      "required" => true,
      "block" => "nation_applicability",
      "attribute_path" => %w[block_content nation_applicability],
      "translatable" => false,
    }
    @path = ConfigurableContentBlocks::Path.new(%w[block_content nation_applicability])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "nation_applicability" => @field },
        },
      },
      "schema" => {
        "attributes" => {
          "nation_applicability" => {
            "type" => "object",
          },
        },
      },
    }))
    @block = ConfigurableContentBlocks::NationApplicability.new(@edition, @field, @path)
  end

  test "it renders a checkbox for applying to all UK nations, and one for each excludable nation" do
    render @block

    assert_dom "input[type=checkbox][name='edition[block_content][nation_applicability][]'][value='all']"
    assert_dom "label", text: "Applies to all UK nations"
    assert_dom "input[type=checkbox][name='edition[block_content][nation_applicability][]'][value='england']"
    assert_dom "label", text: "Does not apply to England"
    assert_dom "input[type=checkbox][name='edition[block_content][nation_applicability][]'][value='scotland']"
    assert_dom "label", text: "Does not apply to Scotland"
    assert_dom "input[type=checkbox][name='edition[block_content][nation_applicability][]'][value='wales']"
    assert_dom "label", text: "Does not apply to Wales"
    assert_dom "input[type=checkbox][name='edition[block_content][nation_applicability][]'][value='northern_ireland']"
    assert_dom "label", text: "Does not apply to Northern Ireland"
  end

  test "it renders the required label" do
    render @block

    assert_dom "legend, .govuk-fieldset__legend", text: /Nation applicability \(required\)/
  end

  test "it checks the boxes for the currently selected values" do
    @edition.block_content = { "nation_applicability" => %w[england wales] }

    render @block

    assert_dom "input[value='england'][checked]"
    assert_dom "input[value='wales'][checked]"
    assert_dom "input[value='scotland']:not([checked])"
    assert_dom "input[value='all']:not([checked])"
  end

  test "it checks the 'applies to all UK nations' box when that is the current selection" do
    @edition.block_content = { "nation_applicability" => %w[all] }

    render @block

    assert_dom "input[value='all'][checked]"
    assert_dom "input[value='england']:not([checked])"
  end

  test "it displays validation errors" do
    @edition.errors.add(:nation_applicability, "- you must select whether this content applies to all UK nations or which nations it does not apply to")

    render @block

    assert_dom ".govuk-error-message"
  end
end
