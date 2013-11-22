class ConsultationsController < DocumentsController
  def index
    clean_search_filter_params
    redirect_to publications_path(publication_type: 'consultations')
  end

  def show
    @related_policies = @document.published_related_policies
    set_slimmer_headers_for_document(@document)
    set_meta_description(@document.summary)
    expire_on_open_state_change(@document)
  end

  private

  def document_class
    Consultation
  end
end
