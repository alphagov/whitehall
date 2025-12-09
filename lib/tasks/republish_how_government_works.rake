desc "Republishes how government works page"
task republish_how_government_works: :environment do
  PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter")
end
