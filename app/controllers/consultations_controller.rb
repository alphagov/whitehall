class ConsultationsController < DocumentsController
  helper_method :scope_description

  def index
    load_consultations_from_scope(Consultation)
    @featured_consultations = Consultation.published.featured.by_published_at.limit(3)
  end

  def open
    load_consultations_from_scope(Consultation.open)
    @featured_consultations = []
    render :index
  end

  def closed
    load_consultations_from_scope(Consultation.closed)
    @featured_consultations = []
    render :index
  end

  private

  def load_consultations_from_scope(scope)
    @consultations = scope.published.by_published_at
  end

  def document_class
    Consultation
  end

  def scope_description
    params[:action] == 'index' ? '' : ' ' + params[:action]
  end
end