module PublishingApi
  module PayloadBuilder
    class BrexitNoDealContent
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        return {} if hide_no_deal_notice?

        { brexit_no_deal_notice: links }
      end

    private

      def links
        non_blank_links.map do |link|
          {
            title: link.title,
            href: href(link),
          }
        end
      end

      def non_blank_links
        item.brexit_no_deal_content_notice_links.reject do |link|
          link.title.blank? && link.url.blank?
        end
      end

      def href(link)
        return URI.parse(link.url).path if link.is_internal?

        link.url
      end

      def hide_no_deal_notice?
        !item.try(:show_brexit_no_deal_content_notice)
      end
    end
  end
end
