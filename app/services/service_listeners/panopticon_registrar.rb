module ServiceListeners
  class PanopticonRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      PanopticonRegisterArtefactWorker.perform_async(@edition.id)
    end
  end
end
