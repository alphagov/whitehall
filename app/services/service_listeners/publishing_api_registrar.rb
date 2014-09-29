module ServiceListeners
  class PublishingApiRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      PublishingApiRegisterArtefactWorker.perform_async(@edition.id)
    end
  end
end
