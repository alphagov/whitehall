class ConsultationsController < DocumentsController
  def index
    redirect_to open_consultations_path
  end

  def open
    load_consultations_from_scope(Consultation.open)
    render :index
  end

  def closed
    load_consultations_from_scope(Consultation.closed)
    render :index
  end

  def upcoming
    load_consultations_from_scope(Consultation.upcoming)
    render :index
  end

  private

  def load_consultations_from_scope(scope)
    @consultations = scope.published.by_publication_date
  end

  def document_class
    Consultation
  end
end