module Whitehall
  module GovUkDelivery
    class Notifier
      attr_accessor :edition

      def initialize(edition)
        @edition = edition
      end

      def edition_published!
        if should_notify_govuk_delivery?
          Whitehall::GovUkDelivery::Worker.notify!(edition, notification_date)
        end
      end

    protected

      def should_notify_govuk_delivery?
        edition.published? &&
        edition_type_is_deliverable? &&
        major_change? &&
        published_today? &&
        !outdated_speech? &&
        available_in_english?
      end

      def edition_type_is_deliverable?
        [Announcement, Policy, Publicationesque].any? {|klass| edition.is_a?(klass) }
      end

      def major_change?
        !edition.minor_change?
      end

      def published_today?
        Date.today == notification_date.to_date
      end

      def outdated_speech?
        edition.is_a?(Speech) && edition.first_published_version? && edition.delivered_on < 72.hours.ago
      end

      def available_in_english?
        edition.available_in_locale?(:en)
      end

      def notification_date
        edition.public_timestamp
      end
    end
  end
end
