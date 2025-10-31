module ConfigurableContentBlocks
  class DefaultObject
    attr_reader :block_factory

    def initialize(block_factory)
      @block_factory = block_factory
    end

    def to_partial_path
      "admin/configurable_content_blocks/default_object"
    end

    def publishing_api_payload(schema, content)
      output = {}
      schema["properties"].each do |property_key, property_schema|
        if content[property_key].nil? && property_schema["format"] != "lead_image_select"
          next
        end

        block = block_factory.build(property_schema["type"], property_schema["format"] || "default")
        leaf_block = !%w[object array].include?(property_schema["type"])
        payload = leaf_block ? block.publishing_api_payload(content[property_key]) : block.publishing_api_payload(property_schema, content[property_key])
        output.merge!({ property_key.to_sym => payload })
      end
      output
    end
  end
end
