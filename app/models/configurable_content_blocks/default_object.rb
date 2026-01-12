module ConfigurableContentBlocks
  class DefaultObject
    attr_reader :block_factory

    def initialize(block_factory)
      @block_factory = block_factory
    end

    def to_partial_path
      "admin/configurable_content_blocks/default_object"
    end
  end
end
