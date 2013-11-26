class NoFootnotesInGovspeakValidator < ActiveModel::Validator
  FOOTNOTE_TAG_MATCHER = /(\[\^.*\])/

  def initialize(opts = {})
    @attributes = opts[:attributes] || [opts[:attribute]]
    super
  end

  def validate(record)
    @record = record
    @attributes.each {|attribute_name| validate_attribute_contains_no_footnotes(attribute_name) }
  end

private

  def validate_attribute_contains_no_footnotes(attribute_name)
    if @record.public_send(attribute_name) =~ FOOTNOTE_TAG_MATCHER
      @record.errors.add(attribute_name, "cannot include footnotes on this type of document (#{attribute_name.to_s.humanize} includes '#{$1}')")
    end
  end
end
