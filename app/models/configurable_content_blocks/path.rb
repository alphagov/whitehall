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
      "edition_block_content_#{@segments.join('_')}"
    end

    def form_control_name
      "edition[block_content][#{@segments.join('][')}]"
    end
  end
end
