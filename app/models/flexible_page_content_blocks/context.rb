module FlexiblePageContentBlocks
  module Context
    class << self
      attr_reader :page, :renderer
    end

    def self.create(page, renderer = nil)
      @page = page
      @renderer = renderer
    end
  end
end
