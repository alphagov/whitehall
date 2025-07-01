module FlexiblePageContentBlocks
  module Context
    class << self
      attr_reader :page
    end

    def self.create_for_page(page)
      @page = page
    end
  end
end
