class Admin::CorporateInformationPagesController < Admin::EditionsController
  prepend_before_action :find_organisation

  FakeEditionFilter = Struct.new(:editions, :page_title, :show_stats, :hide_type)

  def index
    params[:state] = "active" # Ensure that state column is displayed.
    @paginator = @organisation.corporate_information_pages.where("state != ?", "superseded").order("corporate_information_page_type_id").page(params["page"].to_i || 1).per(100)
    @filter = FakeEditionFilter.new @paginator, "Corporate information pages", false, true

    render :index
  end

  def destroy
    # The title method relies on the presence of the organisation so we need to
    # stash it before the page is destroyed, as the join model between the page
    # and the organisation will no longer exist afterwards.
    title = @edition.title
    edition_deleter = Whitehall.edition_services.deleter(@edition)
    if edition_deleter.perform!
      redirect_to [:admin, @organisation, CorporateInformationPage], notice: "The document '#{title}' has been deleted"
    else
      redirect_to admin_edition_path(@edition), alert: edition_deleter.failure_reason
    end
  end

private

  def edition_class
    CorporateInformationPage
  end

  def new_edition
    @organisation.build_corporate_information_page(new_edition_params)
  end

  def find_organisation
    @organisation =
      if params.key?(:organisation_id)
        Organisation.friendly.find(params[:organisation_id])
      elsif params.key?(:worldwide_organisation_id)
        WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def document_can_be_previously_published
    false
  end
end
