class PresentPageToPublishingApiWorker < WorkerBase
  def perform(presenter)
    PresentPageToPublishingApi.new.publish(presenter.constantize)
  end
end
