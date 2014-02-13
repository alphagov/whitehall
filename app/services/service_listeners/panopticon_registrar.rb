module ServiceListeners
  class PanopticonRegistrar
    def initialize(edition)
      @edition = edition
    end

    def register!
      if registerable_types.include?(@edition.class)
        PanopticonRegisterArtefactWorker.perform_async(@edition.id)
      end
    end

    private
    def registerable_types
      [ Consultation, DetailedGuide, DocumentCollection, Policy, Publication, StatisticalDataSet ]
    end
  end
end
