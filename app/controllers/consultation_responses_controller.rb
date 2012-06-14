class ConsultationResponsesController < DocumentsController
  def show
    @related_policies = @consultation.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

  private

  def find_document
    @consultation = Consultation.published_as(params[:consultation_id])

    if @consultation && @consultation.published_consultation_response
      @document = @consultation.published_consultation_response
    else
      render text: "Not found", status: :not_found
    end
  end

  def document_class
    ConsultationResponse
  end
end
