class EditionCreateLinkMonitorWorker < WorkerBase
  def perform(id)
    edition = Edition.find_by(id: id)

    return unless edition.present?

    CreateEditionLinkMonitor.new(edition).perform!
  end
end
