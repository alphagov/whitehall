module CssSelectors
  include ActionController::RecordIdentifier
  
  def object_css_selector(object)
    '#' + dom_id(object)
  end
end