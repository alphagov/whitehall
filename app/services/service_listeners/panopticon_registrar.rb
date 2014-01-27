module ServiceListeners
  class PanopticonRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      if @edition.is_a? DetailedGuide
        PanopticonRegisterArtefactWorker.perform_async(@edition.id)
      end
    end
  end
end
