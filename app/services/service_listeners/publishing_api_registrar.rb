module ServiceListeners
  class PublishingApiRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      PublishingApiEditionWorker.perform_async(@edition.id)
    end
  end
end
