module ConfigurableContentBlocks
  class DefaultString
    def json_schema_type
      "string"
    end

    def json_schema_format
      "default"
    end

    def publishing_api_payload(content)
      content
    end

    def to_partial_path
      "admin/configurable_content_blocks/default_string"
    end
  end
end
