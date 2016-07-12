module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path

      def self.for(base_path)
        new(base_path).call
      end

      def initialize(base_path)
        @base_path = base_path
      end

      def call
        { routes: [{ path: base_path, type: "exact" }] }
      end
    end
  end
end
