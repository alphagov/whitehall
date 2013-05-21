class GroupsController < PublicFacingController
  def show
    @organisation = Organisation.find(params[:organisation_id])
    @group = @organisation.groups.find_by_slug!(params[:id])
    @group_members = @group.members.map do |p|
      [
        PersonPresenter.new(p, view_context),
        p.current_roles.map { |r| RolePresenter.new(r, view_context) }
      ]
    end
    set_slimmer_organisations_header([@organisation])
  end
end
