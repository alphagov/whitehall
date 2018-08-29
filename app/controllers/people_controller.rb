class PeopleController < PublicFacingController
  enable_request_formats show: [:atom]

  def show
    respond_to do |format|
      format.html do
        @person = PersonPresenter.new(Person.friendly.find(params[:id]), view_context)
        @content_item = Whitehall.content_store.content_item(@person.path)
        set_meta_description("Biography of #{@person.name}.")
        set_slimmer_organisations_header(@person.organisations)
        set_slimmer_page_owner_header(@person.organisations.first)
      end

      format.atom do
        redirect_to "/government/announcements.atom?people[]=#{params[:id]}"
      end
    end
  end
end
