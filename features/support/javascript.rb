require "slimmer/test"

Before("@javascript") do
  ENV["USE_SLIMMER"] = "true"
end

After("@javascript") do
  ENV.delete("USE_SLIMMER")

  errors = page.driver.browser.logs.get(:browser)
  if errors.present?
    errors.each do |error|
      warn "javascript: #{error.level}:"
      warn error.message
    end
  end
end

module JavascriptHelper
  def running_javascript?
    Capybara.current_driver == Capybara.javascript_driver
  end

  def wait_for(max_wait_time = Capybara.default_max_wait_time, &block)
    Selenium::WebDriver::Wait.new(timeout: max_wait_time).until(&block)
  end

  def wait_for_change_to(element)
    original_html = element["innerHTML"]
    wait_for { element["innerHTML"] != original_html }
  end
end

World(JavascriptHelper)

# Capybara 2 is a lot stricter with the elements that it finds. Not only does it complain if your
# selector matches more than one element, but it also doesn't like interacting with invisible elements.
# And because we use the chosen jQuery extension to enhance admin form select fields, we need some
# jiggery pokery to make sure we can select stuff in our javascript-enabled tests.
module Capybara::DSL
  def select(value, options = {})
    if options.key?(:from)
      element = find(:select, options[:from], visible: :all).find(:option, value, visible: :all)
      if element.visible?
        from = options.delete(:from)
        find(:select, from, **options).find(:option, value, **options).select_option
      else
        select_from_chosen(value, options)
      end
    else
      find(:option, value, **options).select_option
    end
  end

  def select_from_chosen(value, options = {})
    field = find_field(options[:from], visible: false, match: :first)
    option_value = evaluate_script("$(\"##{field[:id]} option:contains('#{value}')\").val()")

    if field.multiple?
      execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
      option_value = evaluate_script("value")
    end

    execute_script("$('##{field[:id]}').val(#{option_value.to_json})")
    execute_script("$('##{field[:id]}').trigger('liszt:updated').trigger('change')")
  end
end
