module Admin::DashboardHelper

  def organisation_acronym_or_name(organisation)
    organisation.acronym.presence || organisation.name
  end
end
