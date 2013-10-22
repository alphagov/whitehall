class Whitehall::GovUkDelivery::Notifier
  attr_accessor :edition

  def self.edition_published(edition, options)
    if edition.supports_govuk_delivery_notifications?
      new(edition).edition_published!
    end
  end

  def initialize(edition)
    @edition = edition
  end

  def edition_published!
    if edition_can_be_sent_as_notification?
      if edition.relevant_to_local_government?
        notify_email_curation_queue
      else
        notify_govuk_delivery
      end
    end
  end

  def notify_email_curation_queue
    Whitehall::GovUkDelivery::EmailCurationQueueEndPoint.new(edition, notification_date).notify!
  end

  def notify_govuk_delivery
    Whitehall::GovUkDelivery::GovUkDeliveryEndPoint.new(edition, notification_date).notify!
  end

  def edition_can_be_sent_as_notification?
    !edition.minor_change? &&
      # We don't want to send anything that will appear to have been
      # published in the past.
      (Time.zone.now.to_date == notification_date.to_date) &&
      edition.available_in_locale?(:en)
  end

  def notification_date
    case edition
    when Speech
      edition.major_change_published_at
    else
      edition.public_timestamp
    end
  end
end
