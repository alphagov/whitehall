module Govspeak
  class OrphanedHeadingError < StandardError
    attr_reader :heading

    def initialize(heading)
      @heading = heading
      super("Parent heading missing for: #{heading}")
    end
  end
end
