# extend, so that we get the implementation of notify_from_queue!
class RememberingNotificationEndPoint < Whitehall::GovUkDelivery::GovUkDeliveryEndPoint
  # this isn't thread-safe - not a huge problem as we use mocha, which
  # also isn't thread-safe, but if we want to parallelize the tests using
  # a single process, we'll need to deal with this too.
  def self.remember!(initialize_args)
    self.memories << initialize_args
  end
  def self.memories
    @memory ||= []
  end
  def self.mind_wipe!
    self.memories.clear
  end
  def initialize(*args)
    RememberingNotificationEndPoint.remember!(args)
  end
  def notify!
  end
end

Before("@gov-uk-delivery-remembers-notifications") do
  RememberingNotificationEndPoint.mind_wipe!
  @original_gov_uk_delivery_notification_end_point = Whitehall::GovUkDelivery::GovUkDeliveryEndPoint
  silence_warnings { Whitehall::GovUkDelivery::GovUkDeliveryEndPoint = RememberingNotificationEndPoint }
end

After("@gov-uk-delivery-remembers-notifications") do
  silence_warnings { Whitehall::GovUkDelivery::GovUkDeliveryEndPoint = @original_gov_uk_delivery_notification_end_point }
end