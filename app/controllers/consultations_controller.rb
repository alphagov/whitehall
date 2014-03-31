class ConsultationsController < DocumentsController
  def index
    filter_params = params.except(:controller, :action, :format, :_)
    redirect_to publications_path(filter_params.merge(publication_filter_option: 'consultations'))
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
