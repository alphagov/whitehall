module PublishingApi
  module PayloadBuilder
    class BrexitContentNotices
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        return {} if no_brexit_content_notices?

        show_no_deal_notice? ? no_deal_notice_payload : current_state_notice_payload
      end

    private

      def no_deal_notice_payload
        { brexit_no_deal_notice: no_deal_links }
      end

      def current_state_notice_payload
        { brexit_current_state_notice: current_state_links }
      end

      def no_brexit_content_notices?
        hide_no_deal_notice? && hide_current_state_notice?
      end

      def no_deal_links
        links_for_payload(item.brexit_no_deal_content_notice_links)
      end

      def current_state_links
        links_for_payload(item.brexit_current_state_content_notice_links)
      end

      def links_for_payload(links)
        non_blank_links(links).map do |link|
          to_hash(link)
        end
      end

      def to_hash(link)
        {
          title: link.title,
          href: href(link),
        }
      end

      def non_blank_links(links)
        links.reject do |link|
          link.title.blank? && link.url.blank?
        end
      end

      def href(link)
        return URI.parse(link.url).path if link.is_internal?

        link.url
      end

      def show_no_deal_notice?
        item.try(:show_brexit_no_deal_content_notice)
      end

      def hide_no_deal_notice?
        !show_no_deal_notice?
      end

      def show_current_state_notice?
        item.try(:show_brexit_current_state_content_notice)
      end

      def hide_current_state_notice?
        !show_current_state_notice?
      end
    end
  end
end
