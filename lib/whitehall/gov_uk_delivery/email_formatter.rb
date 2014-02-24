module Whitehall
  module GovUkDelivery
    class EmailFormatter < Struct.new(:edition, :notification_date, :title, :summary)

      def initialize(edition, notification_date, options = {})
        options[:title] ||= edition.title
        options[:summary] ||= edition.summary
        super(edition, Time.zone.parse(notification_date), options[:title], options[:summary])
      end

      def display_title
        if edition.is_a?(WorldLocationNewsArticle)
          "News story: #{title}"
        else
          "#{edition.display_type}: #{title}"
        end
      end

      def email_body
        %Q( <div class="rss_item" style="margin-bottom: 2em;">
              <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
                <a href="#{url}" style="font-weight: bold; ">#{escape(display_title)}</a>
              </div>
              #{public_date_html}
              <br />
              <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">#{description}</div>
            </div> )
      end

    protected

      def url
        Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol).document_url(edition)
      end

      def public_date_html
        if public_date
          %Q(<div class="rss_pub_date" style="font-size: 90%; margin: 0 0 0.3em; padding: 0; color: #666666; font-style: italic;">#{public_date}</div>)
        end
      end

      def public_date
        if notification_date
          notification_date.strftime('%e %B, %Y at %I:%M%P')
        end
      end

      def description
        [escape(update_information), escape(summary)].delete_if(&:blank?).join('<br /><br />')
      end

      def update_information
        unless edition.first_published_major_version?
          "[Updated: #{edition.document.change_history.first.note}]"
        end
      end

      def escape(string)
        ERB::Util.html_escape(string)
      end
    end
  end
end
