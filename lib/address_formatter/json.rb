require 'address_formatter/formatter'
require 'address_formatter/text'

module AddressFormatter
  class Json < Formatter
    def render(type = nil)
      {
        'address' => {
          'adr' => get_address_as_adr_value(type),
          'label' => get_addresss_as_label_value(type)
        }
      }
    end

  private

    def get_address_as_adr_value(type)
      add_optional_type_key(type, Formatter.property_keys.inject({}) do |adr, key|
        value = properties[key]
        adr.update(key.to_s => value.present? ? value : '')
      end)
    end

    def get_addresss_as_label_value(type)
      text_address = AddressFormatter::Text.new(properties, country_code).render

      add_optional_type_key(type, 'value' => text_address)
    end

    def add_optional_type_key(type, json)
      if type.blank?
        json
      else
        json.update('type' => type)
      end
    end
  end
end
