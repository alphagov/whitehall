class UpdateOrganisationsIndexPageWorker < WorkerBase
  def perform
    PublishOrganisationsIndexPage.new.publish
  end
end
