# Based on https://gist.github.com/michael-harrison/4102026
#
module ChznHelper
  def select_from_chzn(label_text, value)
    field = find_field(label_text, visible: false)
    option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{value}')\").val()")
    page.execute_script("$('##{field[:id]}').val('#{option_value}')")
    page.execute_script("$('##{field[:id]}').trigger('chosen:updated.chosen').trigger('change')")
  end
end

World(ChznHelper)
