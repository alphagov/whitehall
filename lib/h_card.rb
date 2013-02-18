# encoding: utf-8

class HCard
  attr_reader :properties, :country_code

  def initialize(properties, country_code)
    @properties = properties
    @country_code = country_code
  end

  def render
    "<div class=\"vcard\">\n<div class=\"adr\">\n#{address_tags}\n</div>\n</div>"
  end

  def address_tags
    format_string = address_format_string
    property_keys.each do |key|
      format_string.gsub!(/\{\{#{key}\}\}/, hcard_property_tag(key))
    end
    format_string.gsub(/\n/, "<br />\n")
  end

  def property_keys
    ['fn','street-address', 'postal-code', 'locality', 'region', 'country-name']
  end

  def hcard_property_tag(name)
    properties[name] ? "<span class=\"#{name}\">#{properties[name]}</span>" : ""
  end

  def address_format_string
    if country_code == 'GB'
      "{{fn}}\n{{street-address}}\n{{locality}}\n{{region}}\n{{postal-code}}\n{{country-name}}"
    elsif country_code == 'ES'
      "{{fn}}\n{{street-address}}\n{{postal-code}} {{locality}} {{region}}\n{{country-name}}"
    else
      "〒{{postal-code}}\n{{region}}{{locality}}{{street-address}}\n{{fn}}\n{{country-name}}"
    end
  end
end
