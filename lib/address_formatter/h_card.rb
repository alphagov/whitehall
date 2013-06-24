require 'erb'
require 'active_support/core_ext/string'
require 'address_formatter/formatter'

module AddressFormatter
  class HCard < Formatter

    def render
      "<p class=\"adr\">\n#{interpolate_address_template}\n</p>\n".html_safe
    end

    def interpolate_address_template
      replace_newlines_with_break_tags(super)
    end

    def interpolate_address_property(property_name)
      value = super
      value.present? ? "<span class=\"#{property_name}\">#{ERB::Util.html_escape(value)}</span>" : ""
    end

    private

    def replace_newlines_with_break_tags(string)
      string.
        gsub(/^\n/,'').         # get  rid of blank lines
        strip.                  # get rid of any trailing whitespace
        gsub(/\n/, "<br />\n")  # add break tags where appropriate
    end
  end
end
