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
  end
end
