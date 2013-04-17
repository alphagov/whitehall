class Whitehall::GovUkDelivery::EmailCurationQueueEndPoint < Whitehall::GovUkDelivery::NotificationEndPoint
  def notify!
    EmailCurationQueueItem.create_from_edition(edition, notification_date)
  end
end
