module PublishingApi
  module PayloadBuilder
    class PublicDocumentPath
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { base_path: }.merge(PayloadBuilder::Routes.for(base_path))
      end

    private

      def base_path
        @base_path ||= item.public_path(locale: I18n.locale)
      end
    end
  end
end
