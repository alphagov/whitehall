require "json_schemer"

class SchemaValidator
  attr_reader :errors, :schema

  def initialize(document)
    @document = document

    schema_path = Rails.root.join("public/configurable-document-type.schema.json")
    @schema = JSON.parse(File.read(schema_path))

    @schema_validator = JSONSchemer.schema(schema)

    @errors = []
  end

  def self.for(document)
    new(document).call
  end

  def call
    validate
  end

  def validate
    @errors += @schema_validator.validate(@document).to_a.map { |e| e["error"] }

    @errors += [
      all_schema_attributes_used_in_form_fields?,
      all_form_fields_used_in_schema_attributes?,
      all_validation_properties_defined_in_schema?,
    ].compact
  end

private

  def all_validation_properties_defined_in_schema?
    no_exclusive_keys(validation_properties, schema_attributes, proc { |keys| "Schema has properties #{keys} in validators that are not defined in schema attributes" })
  end

  def all_schema_attributes_used_in_form_fields?
    no_exclusive_keys(schema_attributes, form_fields, proc { |keys| "Schema has schema attributes #{keys} that are not used in the forms attribute" })
  end

  def all_form_fields_used_in_schema_attributes?
    no_exclusive_keys(form_fields, schema_attributes, proc { |keys| "Schema has form fields #{keys} that are not defined in schema attributes" })
  end

  def no_exclusive_keys(target_list, comparison_list, message)
    exclusive_keys = (target_list - comparison_list) + (comparison_list - target_list)
    message.call((target_list & exclusive_keys).join(", ")) if (target_list & exclusive_keys).any?
  end

  def validation_properties
    attributes = (@document["schema"]["validations"] || {})&.values&.flat_map { |validator| validator["attributes"] }

    attributes.flat_map do |attribute|
      if !schema_attributes.include?(attribute) && @document["schema"]["validations"].dig(attribute, "fields").present?
        @document["schema"]["validations"][attribute]["fields"].values
      else
        attribute
      end
    end
  end

  def schema_attributes
    obj_dig(@document, "attributes", %w[schema])
  end

  def form_fields
    (@document["forms"] || [])&.keys&.flat_map { |key| obj_dig(@document, "fields", ["forms", key]) }
  end

  def obj_dig(obj, attr, keys)
    dig_keys = obj.dig(*keys + [attr])&.keys

    return keys.last if dig_keys.nil?

    dig_keys.flat_map { |dig_key| obj_dig(obj, attr, keys + [attr, dig_key]) }
  end
end
