module PublishingApi
  module PayloadBuilder
    class People
      attr_reader :item, :key

      def self.for(item, key)
        self.new(item, key).call
      end

      def initialize(item, key)
        @item = item
        @key = key
      end

      def call
        people
      end

    private

      def people
        {
          key => role_appointments
            .map(&:person)
            .collect(&:content_id)
        }
      end

      def role_appointments
        Array(item.try(:role_appointments)) + Array(item.try(:role_appointment))
      end
    end
  end
end
