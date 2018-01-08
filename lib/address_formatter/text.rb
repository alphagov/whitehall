require 'address_formatter/formatter'

module AddressFormatter
  class Text < Formatter

    def render
      strip_blank_lines(interpolate_address_template)
    end

  private
    def strip_blank_lines(address)
      address.gsub(/\n{2,}/, "\n").gsub(/\A\n|\n\Z/, '')
    end
  end
end
