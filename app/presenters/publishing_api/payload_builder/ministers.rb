module PublishingApi
  module PayloadBuilder
    class Ministers
      extend Forwardable

      attr_accessor :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        return {} unless ministers.present?

        { ministers: ministers.collect(&:content_id) }
      end

    private

      def_delegator :item, :role_appointments

      def ministers
        role_appointments.try(:collect, &:person)
      end
    end
  end
end
