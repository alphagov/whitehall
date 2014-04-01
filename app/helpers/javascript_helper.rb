module JavascriptHelper
  def initialise_script(constructor_or_singleton_name, params = {})
    content_for :javascript_initialisers, initialisation_script(constructor_or_singleton_name, params)
  end

  # real browsers and IE9+ are collectively refered to as modern browsers
  def initialise_script_on_modern_browsers(constructor_or_singleton_name, params = {})
    content_for :javascript_initialisers_for_modern_browsers, initialisation_script(constructor_or_singleton_name, params)
  end

  def initialisation_script(constructor_or_singleton_name, params)
    raw("GOVUK.init(#{constructor_or_singleton_name}, #{params.to_json});\n");
  end
end
