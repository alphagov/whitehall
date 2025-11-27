module ConfigurableContentBlocks
  class DefaultDate
    def publishing_api_payload(content)
      content&.rfc3339
    end

    def to_partial_path
      "admin/configurable_content_blocks/default_date"
    end
  end
end
