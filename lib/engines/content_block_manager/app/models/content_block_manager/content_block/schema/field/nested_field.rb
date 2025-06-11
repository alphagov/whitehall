module ContentBlockManager
  module ContentBlock
    class Schema
      class Field
        class NestedField < Field
          attr_reader :parent_name

          def initialize(name:, parent_name:, schema:, properties:, config:)
            @parent_name = parent_name
            @properties = properties
            @config = config
            super(name, schema)
          end
        end
      end
    end
  end
end
