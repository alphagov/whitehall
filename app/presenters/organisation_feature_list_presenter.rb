class OrganisationFeatureListPresenter < FeatureListPresenter
  
  delegate_instance_methods_of FeatureList

  def initialize(organisation, view_context)
    @organisation = organisation
    super(@organisation.feature_list_for_locale(I18n.locale), view_context)
  end

  def limit
    @organisation.organisation_type.sub_organisation? ? 5 : 6
  end
end
