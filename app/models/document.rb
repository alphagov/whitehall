class Document
  class << self
    delegate :find, :search_index, to: Edition
    def method_missing(symbol, *args, &block)
      Edition.send(symbol, *args, &block)
    end
  end
end
