module PublishingApi
  module PayloadBuilder
    class SocialMediaLinks
      def self.for(item)
        new(item).call
      end

      def initialize(item)
        self.item = item
      end

      def call
        return {} unless item.respond_to?(:social_media_accounts)

        {
          social_media_links: item.social_media_accounts.map do |social_media_account|
            {
              href: social_media_account.url,
              service_type: social_media_account.service_name.parameterize,
              title: social_media_account.display_name,
            }
          end,
        }
      end

    private

      attr_accessor :item
    end
  end
end
