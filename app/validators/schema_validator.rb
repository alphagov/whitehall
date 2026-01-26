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
    ].compact
  end

private

  def all_schema_attributes_used_in_form_fields?
    message = proc { |keys| "Schema has schema attributes #{keys} that are not used in the forms attribute" }
    no_exclusive_keys(schema_attributes, form_fields, message)
  end

  def all_form_fields_used_in_schema_attributes?
    message = proc { |keys| "Schema has form fields #{keys} that are not defined in schema attributes" }
    no_exclusive_keys(form_fields, schema_attributes, message)
  end

  def no_exclusive_keys(target_list, comparison_list, message)
    exclusive_keys = (target_list - comparison_list) + (comparison_list - target_list)
    message.call((target_list & exclusive_keys).join(", ")) if (target_list & exclusive_keys).any?
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
