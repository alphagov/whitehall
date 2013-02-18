class HCard
  attr_reader :properties, :country_code

  def initialize(properties, country_code)
    @properties = properties
    @country_code = country_code
  end

  def render
"<div class=\"vcard\">\n  <div class=\"adr\">\n" <<
"    #{hcard_property_tag('fn')}<br />\n" <<
"    #{hcard_property_tag('street-address')}<br />\n" <<
"    #{hcard_property_tag('postal-code')}<br />\n" <<
"    #{hcard_property_tag('locality')}<br />\n" <<
"    #{hcard_property_tag('region')}<br />\n" <<
"    #{hcard_property_tag('country-name')}\n" <<
"  </div>\n</div>"
  end

  def hcard_property_tag(name)
    "<span class=\"#{name}\">#{properties[name]}</span>"
  end
end
