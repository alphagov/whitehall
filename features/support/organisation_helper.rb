module OrganisationHelper
  def find_or_create_organisation(name)
    Organisation.find_by_name(name) || create(:organisation, name: name)
  end
end

World(OrganisationHelper)
