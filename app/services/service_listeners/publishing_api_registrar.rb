module ServiceListeners
  class PublishingApiRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      PublishingApiWorker.perform_async(@edition.class.name, @edition.id)
    end
  end
end
