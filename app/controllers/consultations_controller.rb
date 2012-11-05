class ConsultationsController < DocumentsController
  def index
    redirect_to publications_path(publication_type: 'consultations')
  end

  def show
    @related_policies = @document.published_related_policies
  end

  private

  def document_class
    Consultation
  end
end
