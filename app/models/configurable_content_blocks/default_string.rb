module ConfigurableContentBlocks
  class DefaultString
    def publishing_api_payload(content)
      content
    end

    def to_partial_path
      "admin/configurable_content_blocks/default_string"
    end
  end
end
