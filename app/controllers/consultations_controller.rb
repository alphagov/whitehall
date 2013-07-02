class ConsultationsController < DocumentsController
  def index
    redirect_to publications_path(publication_type: 'consultations')
  end

  def show
    @related_policies = @document.published_related_policies
    set_slimmer_organisations_header(@document.organisations)
    set_slimmer_page_owner_header(@document.lead_organisations.first)
  end

  private

  def document_class
    Consultation
  end
end
