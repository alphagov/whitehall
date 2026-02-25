module ConfigurableContentBlocks
  class Path
    def initialize(segments = [])
      @segments = segments
    end

    def push(segments = [])
      self.class.new([*@segments, *segments])
    end

    def to_a
      @segments
    end

    def form_control_id
      "edition_#{@segments.join('_')}"
    end

    def form_control_name
      "edition[#{@segments.join('][')}]"
    end

    def multiparameter_form_control_name(index)
      "edition[#{@segments.join('][')}][#{index}]"
    end

    def validation_error_attribute
      if @segments.first == "block_content"
        @segments[1..].join(".")
      else
        @segments.join(".")
      end
    end
  end
end
