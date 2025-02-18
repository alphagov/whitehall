require "component_test_helper"

class AutocompleteComponentTest < ComponentTestCase
  def component_name
    "autocomplete"
  end

  def component_data
    {
      id: "id",
      name: "name",
      label: "text",
      options: [
        { text: "France", value: "fr" },
        { text: "Germany", value: "de" },
        { text: "United Kingdom", value: "uk" },
      ],
    }
  end

  test "fails to render when no parameters given" do
    assert_raise do
      render_component({})
    end
  end

  test "defaults the 'name' to be the same as 'id'" do
    data_without_name = component_data.dup
    data_without_name.delete(:name)
    render_component(data_without_name)
    assert_select ".app-c-autocomplete"
    assert_select ".govuk-select[id='id'][name='id']"
    assert_select ".govuk-label", text: "text"
  end

  test "renders the basic component" do
    render_component(component_data)
    assert_select ".app-c-autocomplete"
    assert_select ".govuk-select[id='id'][name='name']"
    assert_select ".govuk-label", text: "text"
  end

  test "renders with a selected option" do
    data = component_data
    data[:options].first[:selected] = true
    render_component(data)
    assert_select ".app-c-autocomplete .govuk-select option[value='fr'][selected='selected']"
  end

  test "renders with a blank option" do
    data = component_data
    data[:include_blank] = true
    render_component(data)
    assert_select ".app-c-autocomplete .govuk-select option[value='']"
  end

  test "passes heading size to label component" do
    data = component_data
    data[:heading_size] = "xl"
    render_component(data)
    assert_select ".govuk-label.govuk-label--xl"
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
    data[:select] = {}
    data[:select][:multiple] = true
    data[:options].first[:selected] = true
    data[:options].last[:selected] = true
    render_component(data)
    assert_select ".app-c-autocomplete .govuk-select[multiple='multiple']"
    assert_select ".app-c-autocomplete .govuk-select option[value='fr'][selected='selected']"
    assert_select ".app-c-autocomplete .govuk-select option[value='de'][selected='selected']", false
    assert_select ".app-c-autocomplete .govuk-select option[value='uk'][selected='selected']"
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
