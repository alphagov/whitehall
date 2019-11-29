class WorldwideOrganisationPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of WorldwideOrganisation

  def organisation_logo_type
    OrganisationLogoType::SingleIdentity
  end

  def organisation_type
    @organisation_type ||= OrganisationType.find_by(name: "Other")
  end
end
