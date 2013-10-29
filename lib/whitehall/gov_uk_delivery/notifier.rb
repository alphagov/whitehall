class Whitehall::GovUkDelivery::Notifier
  attr_accessor :edition

  def initialize(edition)
    @edition = edition
  end

  def edition_published!
    if should_notify_govuk_delivery?
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

  def should_notify_govuk_delivery?
    edition_type_is_deliverable? && major_change? && published_today? && available_in_english?
  end

  def edition_type_is_deliverable?
    Whitehall::GovUkDelivery.deliverable?(edition)
  end

  def major_change?
    !edition.minor_change?
  end

  def published_today?
    Time.zone.now.to_date == notification_date.to_date
  end

  def available_in_english?
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
