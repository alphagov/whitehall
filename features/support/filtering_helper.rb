module FilteringHelper
  def deselect_all(select_widget_css_selector)
    # This call to `unselect` doesn't work with capybara-webkit because it does
    # not recognise the select as a multi-select.
    # Here's the fix, waiting to be merged:
    # https://github.com/thoughtbot/capybara-webkit/pull/361
    # unselect "All departments", from: "Department"
    page.evaluate_script(%{$("#{select_widget_css_selector} option[value='all']").removeAttr("selected"); 1})
  end
end

World(FilteringHelper)