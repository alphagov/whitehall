require "test_helper"
require "capybara/rails"

class SelectWithSearchTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def load_example(name)
    visit "/component-guide/select_with_search/#{name}/preview"
    assert_selector ".app-c-select-with-search", count: 1
  end

  def rendered_options
    all("option").map(&:text)
  end

  test "it renders a select" do
    load_example "default"
    assert_selector ".govuk-label", text: "My Dropdown"
    within ".govuk-select" do
      assert_equal rendered_options, ["Option one", "Option two", "Option three"]
    end
  end

  test "it renders a select with grouped options" do
    load_example "with_grouped_options"
    assert_selector ".govuk-label", text: "Select a city"

    optgroups = all(".govuk-select optgroup").map { |option| option[:label] }
    assert_equal optgroups, ["England", "Northern Ireland", "Scotland", "Wales"]

    within 'optgroup[label="England"]' do
      assert_equal rendered_options, %w[Bath Bristol London Manchester]
    end

    within 'optgroup[label="Northern Ireland"]' do
      assert_equal rendered_options, %w[Bangor Belfast]
    end

    within 'optgroup[label="Scotland"]' do
      assert_equal rendered_options, %w[Dundee Edinburgh Glasgow]
    end

    within 'optgroup[label="Wales"]' do
      assert_equal rendered_options, %w[Cardiff Swansea]
    end
  end
end
