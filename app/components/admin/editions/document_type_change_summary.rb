class Admin::Editions::DocumentTypeChangeSummary < ViewComponent::Base
  def initialize(edition:, old_type:, new_type:)
    @edition = edition
    @old_type = old_type
    @new_type = new_type
    @diff = @new_type - @old_type
  end

private

  def lost_property_items
    @diff.removed_prop_keys.map do |key|
      schema = @old_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will be LOST - this field exists on “#{@old_type.label}” but not on “#{@new_type.label}”.",
      }
    end
  end

  def new_property_items
    @diff.added_prop_keys.map do |key|
      schema = @new_type.properties[key]
      {
        field: schema["title"] || key.humanize,
        value: "Will need POPULATING - this field exists on “#{@new_type.label}” but not on “#{@old_type.label}”. It will be blank after the change.",
      }
    end
  end

  def lost_association_items
    @diff.removed_assoc_keys.map do |key|
      {
        field: key.humanize,
        value: "Will be LOST - this association exists on “#{@old_type.label}” but not on “#{@new_type.label}”.",
      }
    end
  end

  def new_association_items
    @diff.added_assoc_keys.map do |key|
      {
        field: key.humanize,
        value: "Will need POPULATING - this association exists on “#{@new_type.label}” but not on “#{@old_type.label}”. It will be blank after the change",
      }
    end
  end
end
