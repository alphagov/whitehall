module WithNestedAttributeErrors
  # Errors on array item fields use dotted attribute names like
  # :"social_media_links.0.url" so they can be targeted inline per field.
  # Rails tries to call these as methods during error processing; returning
  # nil here prevents a NoMethodError.
  def method_missing(method_name, *args)
    method_name.to_s.include?(".") ? nil : super
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.include?(".") || super
  end
end
