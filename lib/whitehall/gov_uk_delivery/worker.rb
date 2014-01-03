module Whitehall
  module GovUkDelivery
    class Worker
      include Sidekiq::Worker

      def self.notify!(edition, notification_date, title = nil, summary = nil)
        self.perform_async(edition.id, notification_date.iso8601, title: title, summary: summary)
      end

      def perform(edition_id, notification_date, options = {})
        edition = Edition.find(edition_id)
        endpoint = SubscriptionUrlGenerator.new(edition)

        email_formatter = EmailFormatter.new(edition, notification_date, options)

        Whitehall.govuk_delivery_client.notify(endpoint.subscription_urls, email_formatter.display_title, email_formatter.email_body)
      rescue GdsApi::HTTPErrorResponse => exception
        raise unless exception.code == 400
      end
    end
  end
end
