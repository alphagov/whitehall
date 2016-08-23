module SyncChecker
  class ResultSet
    extend Forwardable

    def initialize(progress_bar)
      @progress_bar = progress_bar
      @results = []
    end

    def_delegators :@results, :[], :each, :map, :length

    def <<(result)
      results << result
      progress_bar.increment
    end

  private

    attr_reader :results, :progress_bar
  end
end
