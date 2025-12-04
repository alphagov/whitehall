module ConfigurableContentBlocks
  class WrapperObject < DefaultObject
    attr_reader :block_factory

    def to_partial_path
      "admin/configurable_content_blocks/default_object"
    end
  end
end
