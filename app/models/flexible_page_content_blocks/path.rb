module FlexiblePageContentBlocks
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
      "edition_flexible_page_content_#{@segments.join('_')}"
    end

    def form_control_name
      "edition[flexible_page_content][#{@segments.join('][')}]"
    end
  end
end
