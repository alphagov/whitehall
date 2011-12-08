class ConsultationsController < DocumentsController
  helper_method :scope_description

  def index
    load_consultations_from_scope(Consultation)
  end

  def open
    load_consultations_from_scope(Consultation.open)
    render :index
  end

  def closed
    load_consultations_from_scope(Consultation.closed)
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