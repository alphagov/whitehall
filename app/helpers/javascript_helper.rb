module JavascriptHelper
  def initialise_script(script_name, params = {})
    content_for :javascript_initialisers, "Whitehall.init(#{script_name}, #{params.to_json})";
  end
end
