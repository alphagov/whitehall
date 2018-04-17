class OrganisationFeatureListPresenter < FeatureListPresenter
  delegate_instance_methods_of FeatureList

  def initialize(organisation, view_context)
    @organisation = organisation
    super(@organisation.feature_list_for_locale(I18n.locale), view_context)
    limit_to 6
  end
end
