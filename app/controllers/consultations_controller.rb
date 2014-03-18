class ConsultationsController < DocumentsController
  def index
    redirect_to publications_path(publication_filter_option: 'consultations')
  end

  def show
    @related_policies = @document.published_related_policies
    set_meta_description(@document.summary)
    expire_on_open_state_change(@document)
  end

  private

  def document_class
    Consultation
  end
end
