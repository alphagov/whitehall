After("@javascript") do
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

# We've also had to add functionality to ensure that Choices.js works as we use
# it in our SelectWithSearch component. Unfortunately, its behaviour is more
# obtuse than Chosen.js because it doesn't preserve the original <select> element.

module Capybara::DSL
  def select(value, options = {})
    if use_choices_select?(value, options)
      select_from_choices(value, options)
    elsif options.key?(:from)
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

  def use_choices_select?(value, options)
    return unless running_javascript?

    return_choices_div(value, options).present?
  end

  def return_choices_div(value, options)
    if options.key?(:from).present?
      # selects based on on id or label pased in and returns the parent div
      find(:select, options[:from], visible: :all).ancestor(".app-c-select-with-search", wait: false)
    else
      # selects based on on value input by the user.
      # will throw and error for ambiguous matches.
      find(
        "div[role='option'][class='choices__item choices__item--choice choices__item--selectable']",
        text: value,
        visible: false,
        wait: false,
      )
       .ancestor(".app-c-select-with-search", wait: false)
    end
  rescue Capybara::ElementNotFound
    nil
  end

  def select_from_choices(value, options)
    div = return_choices_div(value, options)
    select = div.find("select", visible: false)

    # if the option is already selected we don't need to do anything
    # the selector below will complain as the divs masquerading as options
    # are dynamically created/removed when options are selected/deselected
    select_has_value_as_text = all(".choices__list.choices__list--single", visible: false, text: value, wait: false).present?
    return if select_has_value_as_text || select.value == value

    choices_option = div.find(
      "div[role='option'][class='choices__item choices__item--choice choices__item--selectable']",
      text: value,
      visible: false,
    )

    data_value = choices_option["data-value"]

    execute_script("arguments[0].choices.setChoiceByValue(arguments[1])", div, data_value)

    # As we are directly interfacing with the Choices.js API, we need to manually
    # trigger a change event on the hidden <select> element so event listeners
    # know it has changed.
    execute_script("arguments[0].dispatchEvent(new Event('change'))", select)
  end
end
