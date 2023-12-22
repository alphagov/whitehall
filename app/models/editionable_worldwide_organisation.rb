class EditionableWorldwideOrganisation < Edition
  include Edition::Organisations

  def display_type_key
    "editionable_worldwide_organisation"
  end

  def publishing_api_presenter
    PublishingApi::EditionableWorldwideOrganisationPresenter
  end

  def base_path
    "/editionable-world/organisations/#{slug}"
  end
end
