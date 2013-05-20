class WorldwideOrganisationPresenter < Struct.new(:model, :context)

  worldwide_organisation_methods = WorldwideOrganisation.instance_methods - Object.instance_methods
  delegate *worldwide_organisation_methods, to: :model

  def organisation_logo_type
    OrganisationLogoType::SingleIdentity
  end

  def organisation_type
    @other_type ||= OrganisationType.find_by_name('Other')
  end
end
