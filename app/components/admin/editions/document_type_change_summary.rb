class Admin::Editions::DocumentTypeChangeSummary < ViewComponent::Base
  attr_reader :lost_property_items,
              :new_property_items,
              :lost_association_items,
              :new_association_items

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
    removed_assoc_keys = @old_type.associations.map { |a| a["key"] } - @new_type.associations.map { |a| a["key"] }
    added_assoc_keys   = @new_type.associations.map { |a| a["key"] } - @old_type.associations.map { |a| a["key"] }

    @lost_property_items = removed_prop_keys.map do |key|
      schema = @old_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will be LOST - this field exists on “#{@old_type.label}” but not on “#{@new_type.label}”.",
      }
    end

    @new_property_items = added_prop_keys.map do |key|
      schema = @new_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will need POPULATING - this field exists on “#{@new_type.label}” but not on “#{@old_type.label}”. It will be blank after the change.",
      }
    end

    @lost_association_items = removed_assoc_keys.map do |key|
      {
        field: key.humanize,
        value: "Will be LOST - this association exists on “#{@old_type.label}” but not on “#{@new_type.label}”.",
      }
    end

    @new_association_items = added_assoc_keys.map do |key|
      {
        field: key.humanize,
        value: "Will need POPULATING - this association exists on “#{@new_type.label}” but not on “#{@old_type.label}”. It will be blank after the change",
      }
    end
  end
end
