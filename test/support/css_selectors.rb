module CssSelectors
  include ActionController::RecordIdentifier

  def record_css_selector(object)
    '#' + dom_id(object)
  end

  def record_id_from(element)
    element["id"].split("_").last
  end

  def records_from_elements(klass, elements)
    klass.find(elements.map { |element| record_id_from(element) })
  end
end