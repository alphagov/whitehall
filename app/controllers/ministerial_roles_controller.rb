class MinisterialRolesController < PublicFacingController
  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = sorter.cabinet_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }
    @ministerial_roles = sorter.other_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    load_published_documents_in_scope { |scope| scope.in_ministerial_role(@ministerial_role).by_published_at }
    speeches = @ministerial_role.speeches.published

    @announcements = Announcement.sort_by_first_published_at(@news_articles + speeches)
  end
end
