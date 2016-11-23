class PublishingApiServicesAndInformationWorker < PublishingApiWorker
  def perform(organisation_id)
    organisation = Organisation.find(organisation_id)
    if organisation.has_services_and_information_link?
      payload = PublishingApi::ServicesAndInformationPresenter.new(organisation)
      send_item(payload, "en")
    end
  end
end
