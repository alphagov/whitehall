# encoding: utf-8

class HCard
  attr_reader :properties, :country_code

  @address_formats = YAML.load_file(Rails.root.join('config/address_formats.yml'))

  def self.address_formats
    @address_formats
  end

  def initialize(properties, country_code)
    @properties = properties
    @country_code = country_code
  end

  def render
    "<div class=\"vcard\">\n<div class=\"adr\">\n#{address_tags}\n</div>\n</div>\n".html_safe
  end

  private

  def address_tags
    address = format_string_from_country_code
    property_keys.each do |key|
      address.gsub!(/\{\{#{key}\}\}/, hcard_property_tag(key))
    end
    replace_newlines_with_break_tags(address)
  end

  def property_keys
    ['fn','street-address', 'postal-code', 'locality', 'region', 'country-name']
  end

  def hcard_property_tag(name)
    properties[name] ? "<span class=\"#{name}\">#{properties[name]}</span>" : ""
  end

  def format_string_from_country_code
    HCard.address_formats[country_code.downcase].dup
  end

  def replace_newlines_with_break_tags(string)
    string.
    gsub(/^\n/,''). # get  rid of blank lines
    gsub(/\n/, "<br />\n") # add break tags where appropriate
  end
end
