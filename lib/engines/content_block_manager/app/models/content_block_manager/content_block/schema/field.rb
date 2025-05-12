module ContentBlockManager
  module ContentBlock
    class Schema
      class Field
        attr_reader :name, :schema

        def initialize(name, schema)
          @name = name
          @schema = schema
        end

        def to_s
          name
        end
      end
    end
  end
end
