# Strips leading and trailing whitespace from string and text attributes before
# validation, so stray spaces typed or pasted into a form field are not saved.
#
# Only attributes that have changed are stripped, so existing records are not
# rewritten when something else about them is saved. Translated (Globalize)
# attributes are handled too.
module StripsWhitespace
  extend ActiveSupport::Concern

  SURROUNDING_WHITESPACE = /\A[[:space:]]+|[[:space:]]+\z/

  included do
    before_validation :strip_whitespace_from_changed_attributes
  end

private

  def strip_whitespace_from_changed_attributes
    changes.each do |name, (_, value)|
      next unless strippable_attribute?(name)
      next unless value.is_a?(String) && value.valid_encoding?

      stripped = value.gsub(SURROUNDING_WHITESPACE, "")
      write_attribute(name, stripped) unless stripped == value
    end
  end

  # Globalize translated attributes (title, name, summary etc.) are stored on a
  # separate model but read and written through the parent, so they have no
  # column of their own here.
  def strippable_attribute?(name)
    type = if translated_attribute?(name)
             self.class::Translation.type_for_attribute(name).type
           else
             type_for_attribute(name).type
           end

    type.in?(%i[string text])
  end

  def translated_attribute?(name)
    self.class.respond_to?(:translated_attribute_names) && self.class.translated_attribute_names.include?(name.to_sym)
  end
end
