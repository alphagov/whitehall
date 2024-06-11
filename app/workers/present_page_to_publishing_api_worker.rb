class PresentPageToPublishingApiWorker < WorkerBase
  def perform(presenter, update_live = true)
    if update_live
      PresentPageToPublishingApi.new.publish(presenter.constantize)
    else
      PresentPageToPublishingApi.new.save_draft(presenter.constantize)
    end
  end
end
