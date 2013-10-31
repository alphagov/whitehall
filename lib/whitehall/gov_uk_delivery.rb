module Whitehall
  module GovUkDelivery
    autoload :Notifier, 'whitehall/gov_uk_delivery/notifier'
    autoload :NotificationEndPoint, 'whitehall/gov_uk_delivery/notification_end_point'
    autoload :EmailCurationQueueEndPoint, 'whitehall/gov_uk_delivery/email_curation_queue_end_point'
    autoload :GovUkDeliveryEndPoint, 'whitehall/gov_uk_delivery/gov_uk_delivery_end_point'

    DELIVERABLE_EDITION_CLASSES = [Announcement, Policy, Publicationesque]

    def self.deliverable?(edition)
      DELIVERABLE_EDITION_CLASSES.any? {|klass| edition.is_a?(klass) }
    end
  end
end
