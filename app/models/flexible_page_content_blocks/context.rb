module FlexiblePageContentBlocks
  module Context
    class << self
      attr_reader :page
    end
    def self.create(page)
      @page = page
    end
  end
end
