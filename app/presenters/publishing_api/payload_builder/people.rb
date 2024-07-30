module PublishingApi
  module PayloadBuilder
    class People
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        people
      end

    private

      def people
        {
          people: role_appointments
            .map(&:person)
            .collect(&:content_id)
            .uniq,
        }
      end

      def role_appointments
        Array(item.try(:role_appointments)) + Array(item.try(:role_appointment))
      end
    end
  end
end
