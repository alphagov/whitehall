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
        block = block_factory.build(property_schema["type"], property_schema["format"] || "default")
        leaf_block = !%w[object array].include?(property_schema["type"])
        # If the leaf itself is an object of format wrapper, then we want to skip ahead to its children
        # example root object with a duration in it:
        # output starts as {}
        # the child is also an object => payload is block.publishing_api_payload(property_schema, content[property_key])
        # property_key = duration
        # {}.merge({duration => payload})
        # the change is to:
        # merge the payload without the duration key
        #
        payload = leaf_block ? block.publishing_api_payload(content[property_key]) : block.publishing_api_payload(property_schema, content[property_key])

        output.merge!({ property_key.to_sym => payload }) unless payload.nil?
      end
      output
    end
  end
end
