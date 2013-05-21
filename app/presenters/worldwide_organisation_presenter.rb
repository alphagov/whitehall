class WorldwideOrganisationPresenter < Whitehall::Decorators::Decorator

  delegate_instance_methods_of WorldwideOrganisation

  def organisation_logo_type
    OrganisationLogoType::SingleIdentity
  end

  def organisation_type
    @other_type ||= OrganisationType.find_by_name('Other')
  end
end
