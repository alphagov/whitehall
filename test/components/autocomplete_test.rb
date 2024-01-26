require "component_test_helper"

class AutocompleteComponentTest < ComponentTestCase
  def component_name
    "autocomplete"
  end

  def component_data
    {
      id: "id",
      name: "name",
      label: {
        text: "text",
      },
      select: {
        options: [
          [""],
          ["France", "fr"],
          ["Germany", "de"],
          ["United Kingdom", "uk"],
        ],
      },
    }
  end

  test "fails to render when no parameters given" do
    assert_raise do
      render_component({})
    end
  end

  test "renders the basic component" do
    render_component(component_data)
    assert_select ".app-c-autocomplete"
    assert_select ".govuk-select[id='id'][name='name']"
    assert_select ".govuk-label", text: "text"
  end

  test "renders with a selected option" do
    data = component_data
    data[:select][:selected] = "de"
    render_component(data)
    assert_select ".app-c-autocomplete .govuk-select option[value='de'][selected='selected']"
  end

  test "renders with an error" do
    data = component_data
    data[:error_items] = [
      {
        text: "whoa something bad happened",
      },
    ]
    render_component(data)
    assert_select ".app-c-autocomplete.govuk-form-group--error .gem-c-error-message", text: "Error: whoa something bad happened"
  end

  test "renders in multiple mode" do
    data = component_data
    data[:select][:multiple] = true
    data[:select][:selected] = %w[fr de]
    render_component(data)
    assert_select ".app-c-autocomplete .govuk-select[multiple='multiple']"
    assert_select ".app-c-autocomplete .govuk-select option[value='fr'][selected='selected']"
    assert_select ".app-c-autocomplete .govuk-select option[value='de'][selected='selected']"
    assert_select ".app-c-autocomplete .govuk-select option[value='uk'][selected='selected']", false
  end

  test "accepts data attribures" do
    data = component_data
    data[:data_attributes] = {
      module: "not-a-module",
      isaac: "asimov",
    }
    render_component(data)
    assert_select ".app-c-autocomplete[data-module='not-a-module autocomplete'][data-isaac='asimov']"
  end

  test "accepts configuration options" do
    data = component_data
    data[:autocomplete_configuration_options] = {
      showAllValues: false,
    }
    render_component(data)
    assert_select ".app-c-autocomplete[data-autocomplete-configuration-options='#{data[:autocomplete_configuration_options].to_json}']"
  end
end
