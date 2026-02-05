module CssSelectors
  include ActionView::RecordIdentifier

  def record_css_selector(object, prefix = nil)
    "##{dom_id(object, prefix)}"
  end
end
