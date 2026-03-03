class Admin::Editions::DocumentTypeChangeSummary < ViewComponent::Base
  attr_reader :lost_property_items,
              :new_property_items,
              :common_association_items

  def initialize(edition:, old_type:, new_type:)
    @edition = edition
    @old_type = old_type
    @new_type = new_type

    compute_diffs
  end

private

  def compute_diffs
    removed_prop_keys = @old_type.properties.keys - @new_type.properties.keys # will be lost
    added_prop_keys   = @new_type.properties.keys - @old_type.properties.keys # will need populating

    @lost_property_items = removed_prop_keys.map do |key|
      schema = @old_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will be <strong>deleted</strong>. A ‘#{@new_type.label}’ does not have a ‘#{schema['title'] || key.humanize}’ field.".html_safe,
      }
    end

    @new_property_items = added_prop_keys.map do |key|
      schema = @new_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will need to be <strong>added</strong>. A ‘#{@new_type.label}’ has a ‘#{schema['title'] || key.humanize}’ field. This field will be blank after the change.".html_safe,
      }
    end
  end
end
