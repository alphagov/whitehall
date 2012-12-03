class PeopleController < PublicFacingController
  def show
    @person = PersonPresenter.decorate(Person.find(params[:id]))

    respond_to do |format|
      format.html do
        set_slimmer_organisations_header(@person.organisations)
      end
      format.atom
    end
  end

  def index
    @people = PersonPresenter.decorate(Person.all)
  end
end
