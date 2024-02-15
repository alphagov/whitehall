module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path, :suffixes

      def self.for(base_path, prefix: false, suffixes: [])
        new(base_path, prefix:, suffixes:).call
      end

      def initialize(base_path, prefix: false, suffixes: [])
        @base_path = base_path
        @prefix = prefix
        @suffixes = suffixes
      end

      def call
        routes = []
        routes << { path: base_path, type: }
        suffixes.each do |suffix|
          routes << { path: "#{base_path}.#{suffix}", type: "exact" }
        end
        { routes: }
      end

    private

      def type
        @prefix ? "prefix" : "exact"
      end
    end
  end
end
