class PeopleController < PublicFacingController
  def show
    @person = PersonPresenter.decorate(Person.find(params[:id]))
    set_slimmer_organisations_header(@person.organisations)
  end

  def index
    @people = PersonPresenter.decorate(Person.all)
  end
end
