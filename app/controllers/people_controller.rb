class PeopleController < PublicFacingController
  def show
    @person = PersonPresenter.new(Person.find(params[:id]), view_context)

    respond_to do |format|
      format.html do
        set_slimmer_organisations_header(@person.organisations)
      end
      format.atom
    end
  end

  def index
    @people = decorate_collection(Person.all, PersonPresenter)
  end
end
