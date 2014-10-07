module ServiceListeners
  class OrganisationPublishingApiRegistrar
    def initialize(organisation)
      @organisation = organisation
    end

    def register!
      PublishingApiRegisterOrganisationWorker.perform_async(@organisation.id)
    end
  end
end
