class HCardAddress
  attr_reader :properties, :country_code

  @address_formats = YAML.load_file(Rails.root.join('config/address_formats.yml'))

  def initialize(properties, country_code)
    @properties = properties
    @country_code = country_code
  end

  def self.address_formats
    @address_formats
  end

  def self.from_contact(contact)
    new(contact_properties(contact), contact.country_code)
  end

  def self.contact_properties(contact)
    { 'fn' => contact.recipient,
      'street-address' => contact.street_address,
      'postal-code' => contact.postal_code,
      'locality' => contact.locality,
      'region' => contact.region,
      'country-name' => country_name(contact) }
  end

  def self.country_name(contact)
    contact.country_name unless contact.country_code == 'GB'
  end

  def render
    "<div class=\"adr\">\n#{address_tags}\n</div>\n".html_safe
  end

  def address_tags
    address = address_template
    property_keys.each do |key|
      address.gsub!(/\{\{#{key}\}\}/, hcard_property_tag(key))
    end
    replace_newlines_with_break_tags(address)
  end

  def property_keys
    ['fn','street-address', 'postal-code', 'locality', 'region', 'country-name']
  end

  def hcard_property_tag(name)
    properties[name].present? ? "<span class=\"#{name}\">#{properties[name]}</span>" : ""
  end

  private

  def address_template
    (HCardAddress.address_formats[country_code.to_s.downcase] || default_format_string).dup
  end

  def default_format_string
    HCardAddress.address_formats['gb']
  end

  def replace_newlines_with_break_tags(string)
    string.
      gsub(/^\n/,'').         # get  rid of blank lines
      strip.                  # get rid of any trailing whitespace
      gsub(/\n/, "<br />\n")  # add break tags where appropriate
  end
end
