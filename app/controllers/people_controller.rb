class PeopleController < PublicFacingController
  enable_request_formats show: [:atom]

  def show
    @person = PersonPresenter.new(Person.friendly.find(params[:id]), view_context)

    respond_to do |format|
      format.html do
        set_meta_description("Biography of #{@person.name}.")
        set_slimmer_organisations_header(@person.organisations)
        set_slimmer_page_owner_header(@person.organisations.first)
      end
      format.atom
    end
  end

  def index
    @people = decorate_collection(Person.all, PersonPresenter)
    set_meta_description("All ministers and senior officials on GOV.UK.")
  end
end
