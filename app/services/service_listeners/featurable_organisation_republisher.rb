class ServiceListeners::FeaturableOrganisationRepublisher
  def initialize(edition)
    @edition = edition
  end

  def call
    @edition.document.features.map(&:republish_featurable_to_publishing_api)
  end
end
