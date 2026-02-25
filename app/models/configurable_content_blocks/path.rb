module ConfigurableContentBlocks
  class Path
    def initialize(segments = [])
      @segments = segments
    end

    def push(segment)
      self.class.new([*@segments, segment])
    end

    def to_a
      @segments
    end

    def form_control_id
      "edition_#{@segments.join('_')}"
    end

    def form_control_name
      "edition[block_content][#{@segments.join('][')}]"
    end

    def multiparameter_form_control_name(index)
      "edition[block_content][#{@segments.join('][')}][#{index}]"
    end

    def validation_error_attribute
      @segments.join(".")
    end
  end
end
