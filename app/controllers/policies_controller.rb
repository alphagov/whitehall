class PoliciesController < DocumentsController
  def show
    @related_publications = Publication.published.related_to(@document)
    @related_consultations = Consultation.published.related_to(@document)
  end

  private

  def document_class
    Policy
  end
end