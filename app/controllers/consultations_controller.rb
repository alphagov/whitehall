class ConsultationsController < DocumentsController
  def index
    @consultations = Consultation.published.by_publication_date
  end

  private

  def document_class
    Consultation
  end
end