class EditionServiceCoordinator
  attr_reader :notifier

  delegate :subscribe, :unsubscribe, :publish, to: :notifier

  def initialize
    @notifier = ActiveSupport::Notifications::Fanout.new
  end

  def publisher(edition, options = {})
    ::EditionPublisher.new(edition, options.merge(notifier: self))
  end

  def force_publisher(edition, options = {})
    ::EditionForcePublisher.new(edition, options.merge(notifier: self))
  end

  def draft_updater(edition, options = {})
    ::DraftEditionUpdater.new(edition, options.merge(notifier: self))
  end

  def scheduler(edition, options = {})
    ::EditionScheduler.new(edition, options.merge(notifier: self))
  end

  def force_scheduler(edition, options = {})
    ::EditionForceScheduler.new(edition, options.merge(notifier: self))
  end

  def unscheduler(edition, options = {})
    ::EditionUnscheduler.new(edition, options.merge(notifier: self))
  end

  def scheduled_publisher(edition, options = {})
    ::ScheduledEditionPublisher.new(edition, options.merge(notifier: self))
  end

  def unpublisher(edition, options = {})
    ::EditionUnpublisher.new(edition, options.merge(notifier: self))
  end

  def withdrawer(edition, options = {})
    ::EditionWithdrawer.new(edition, options.merge(notifier: self))
  end

  def unwithdrawer(edition, options = {})
    ::EditionUnwithdrawer.new(edition, options.merge(notifier: self))
  end

  def deleter(edition, options = {})
    ::EditionDeleter.new(edition, options.merge(notifier: self))
  end
end
