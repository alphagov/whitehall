module ConfigurableDocumentTypes
  class BlockAttribute
    attr_accessor :label, :hint_text, :default, :block, :extract_headings
    def initialize(name, &block)
      @extract_headings = false
      instance_eval(&block)
      raise "You must configure a block for the #{name} attribute" if @block.nil?
      raise "You must configure a label for the #{name} attribute" if @label.nil?
    end

    def cast_type
      @block.active_record_type
    end

    def attribute_options
      {
        default: @default,
      }
    end
  end
end