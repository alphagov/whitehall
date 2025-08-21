module PublishingApi
  module PayloadBuilder
    class Contacts
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        {
          contacts: Govspeak::ContactsExtractor.new(item.body).extracted_contact_ids
        }
      end
    end
  end
end
