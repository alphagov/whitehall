require "json-schema"

# TODO: Rename "validator" to something else
class ObjectStore::ContentBlockValidator
  EMAIL_ADDRESS_SCHEMA = Rails.root.join("lib/engines/object_store/config/object_store/schemas/email_address.json")
  TAX_CODE_SCHEMA = Rails.root.join("lib/engines/object_store/config/object_store/schemas/tax_code.json")

  # TODO: Try a more complex content type?
  SCHEMAS = ActiveSupport::HashWithIndifferentAccess.new(
    "EmailAddress" => JSON.parse(File.read(EMAIL_ADDRESS_SCHEMA)),
    "TaxCode" => JSON.parse(File.read(TAX_CODE_SCHEMA)),
  )

  def self.schema_for(type)
    camel_type = type.split("_").map(&:capitalize).join
    SCHEMAS[camel_type]
  end

  def self.default_properties(type)
    schema = schema_for(type)
    properties = schema[:properties]

    properties.each_with_object({}) do |(key, value), defaults|
      defaults[key] = value[:default] if value.key?(:default)
    end
  end
end
