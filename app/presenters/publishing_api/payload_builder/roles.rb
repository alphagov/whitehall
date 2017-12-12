module PublishingApi
  module PayloadBuilder
    class Roles
      attr_reader :item

      def self.for(item)
        self.new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        roles
      end

    private

      def roles
        {
          roles: role_appointments
            .map(&:role)
            .collect(&:content_id)
            .uniq
        }
      end

      def role_appointments
        Array(item.try(:role_appointments)) + Array(item.try(:role_appointment))
      end
    end
  end
end
