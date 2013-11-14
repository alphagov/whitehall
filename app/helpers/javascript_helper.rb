module JavascriptHelper
  def initialise_script(constructor_or_singleton_name, params = {})
    content_for :javascript_initialisers, raw("GOVUK.init(#{constructor_or_singleton_name}, #{params.to_json});\n");
  end
end
