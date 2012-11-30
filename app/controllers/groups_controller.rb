class GroupsController < PublicFacingController
  def show
    @organisation = Organisation.find(params[:organisation_id])
    @group = @organisation.groups.find_by_slug!(params[:id])
    @group_members = PersonPresenter.decorate(@group.members)
    set_slimmer_organisations_header([@organisation])
  end
end
