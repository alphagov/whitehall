module FlexiblePageContentBlocks
  class DefaultObject
    def json_schema_type
      "object"
    end

    def json_schema_format
      "default"
    end

    def to_partial_path
      "admin/flexible_pages/content_blocks/default_object"
    end

    def publishing_api_payload(schema, content)
      output = {}
      schema["properties"].each do |property_key, property_schema|
        block = Factory.build(property_schema["type"], property_schema["format"] || "default")
        leaf_block = !%w[object array].include?(block.json_schema_type)
        payload = leaf_block ? block.publishing_api_payload(content[property_key]) : block.publishing_api_payload(property_schema, content[property_key])
        output.merge!({ property_key.to_sym => payload })
      end
      output
    end
  end
end
