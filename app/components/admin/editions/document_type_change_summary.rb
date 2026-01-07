class Admin::Editions::DocumentTypeChangeSummary < ViewComponent::Base
  attr_reader :lost_property_items,
              :new_property_items,
              :lost_association_items,
              :new_association_items,
              :common_association_items

  def initialize(edition:, old_type:, new_type:)
    @edition = edition
    @old_type = old_type
    @new_type = new_type
    @association_to_label = {
      "ministerial_role_appointments" => "Ministers",
    }

    compute_diffs
  end

private

  def compute_diffs
    removed_prop_keys = @old_type.properties.keys - @new_type.properties.keys # will be lost
    added_prop_keys   = @new_type.properties.keys - @old_type.properties.keys # will need populating
    removed_assoc_keys = @old_type.associations.map { |a| a["key"] } - @new_type.associations.map { |a| a["key"] }
    added_assoc_keys   = @new_type.associations.map { |a| a["key"] } - @old_type.associations.map { |a| a["key"] }
    common_assoc_keys = @new_type.associations.map { |a| a["key"] } & @old_type.associations.map { |a| a["key"] }

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

    @lost_association_items = build_association_items(removed_assoc_keys, proc { |field| "Will be <strong>deleted</strong>. A ‘#{@new_type.label}’ does not have a ‘#{field}’ association.".html_safe })
    @new_association_items = build_association_items(added_assoc_keys, proc { |field| "Will need to be <strong>added</strong>. A ‘#{@new_type.label}’ has a ‘#{field}’ association. This field will be blank after the change.".html_safe })
    @common_association_items = build_association_items(common_assoc_keys, proc { "These associations will be carried over, you will not have to fill them in again." })
  end

  def build_association_items(items, value)
    items.map do |key|
      field = @association_to_label[key] || key.humanize

      {
        field:,
        value: value.call(field),
      }
    end
  end
end
