class RememberingWorker < Whitehall::GovUkDelivery::Worker
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
  def perform(*args)
    RememberingWorker.remember!(args)
  end
  def notify!
  end
end

Before("@gov-uk-delivery-remembers-notifications") do
  RememberingWorker.mind_wipe!
  @original_gov_uk_delivery_notification_end_point = Whitehall::GovUkDelivery::Worker
  silence_warnings { Whitehall::GovUkDelivery::Worker = RememberingWorker }
end

After("@gov-uk-delivery-remembers-notifications") do
  silence_warnings { Whitehall::GovUkDelivery::Worker = @original_gov_uk_delivery_notification_end_point }
end
