module Whitehall::Controllers::RolesPresenters
  def filled_roles_presenter_for(organisation, association)
    roles_presenter = roles_presenter_for(organisation, association)
    roles_presenter.remove_unfilled_roles!
    roles_presenter
  end

  def roles_presenter_for(organisation, association)
    RolesPresenter.new(organisation.send("#{association}_roles").includes(:translations, :current_people).order("organisation_roles.ordering"))
  end
end
