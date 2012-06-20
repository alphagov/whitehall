class MinisterialRolesController < PublicFacingController
  def index
    @cabinet_ministerial_roles = RolePresenter.decorate(ordered_cabinet_ministerial_roles)
    @ministerial_roles = RolePresenter.decorate(other_ministerial_roles)
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    load_published_documents_in_scope { |scope| scope.in_ministerial_role(@ministerial_role).by_published_at }
    speeches = @ministerial_role.speeches.published

    @announcements = Announcement.by_first_published_at(@news_articles + speeches)
  end

  private

  def other_ministerial_roles
    MinisterialRole.alphabetical_by_person.includes(:current_people) - ordered_cabinet_ministerial_roles
  end

  def ordered_cabinet_ministerial_roles
    @ordered_cabinet_ministerial_roles ||= begin
      roles = MinisterialRole.cabinet.includes(:current_people)
      roles.sort_by { |role| [role.seniority, role.current_person.sort_key] }
    end
  end
end
