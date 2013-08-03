# Based on https://gist.github.com/michael-harrison/4102026
#
module ChznHelper
  def select_from_chzn(field_id, value)
    search_selector = "##{field_id}_chzn input"
    page.execute_script(%Q{$('div##{field_id}_chzn').mousedown()})
    typed = ''
    value.chars.each_with_index do |character, i|
      typed += character
      # Put a value in the search field
      page.execute_script(%Q{$("#{search_selector}").val("#{typed}")})
      # Fire the search via a keyup
      page.execute_script(%Q{$("#{search_selector}").keyup()})
    end
    keyup_event = %Q{jQuery.Event("keyup", { keyCode: $.ui.keyCode.ENTER })}
    page.execute_script(%Q{$("#{search_selector}").trigger(#{keyup_event})})
  end
end

World(ChznHelper)
