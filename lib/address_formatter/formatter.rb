module AddressFormatter
  class Formatter
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

    def self.property_keys
      ['fn', 'street-address', 'postal-code', 'locality', 'region', 'country-name']
    end

    def self.address_formats
      @address_formats
    end

    def self.address_formats=(new_address_formats)
      @address_formats = new_address_formats
    end

    attr_reader :properties, :country_code

    def initialize(properties, country_code)
      @properties = properties
      @country_code = country_code
    end

    def interpolate_address_template
      address = address_template
      Formatter.property_keys.each do |key|
        address.gsub!(/\{\{#{key}\}\}/, interpolate_address_property(key))
      end
      address
    end

    def interpolate_address_property(property_name)
      properties[property_name].present? ? properties[property_name] : ''
    end

  private

    def address_template
      (Formatter.address_formats[country_code.to_s.downcase] || default_format_string).dup
    end

    def default_format_string
      Formatter.address_formats['gb']
    end
  end
end
