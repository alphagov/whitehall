class ConsultationsController < DocumentsController
  helper_method :scope_description
  respond_to :html, :json, :xml

  def index
    scope = Consultation
    @consultations = load_consultations_from_scope(scope)
    @featured_consultation = @consultations.select(&:featured).sort_by {|c| c.published_at }.reverse.first
  end

  def open
    @consultations = load_consultations_from_scope(Consultation.open)
    render :index
  end

  def closed
    @consultations = load_consultations_from_scope(Consultation.closed)
    render :index
  end

  def upcoming
    @consultations = load_consultations_from_scope(Consultation.upcoming)
    render :index
  end

  def show
    @related_policies = @document.published_related_policies
    @policy_topics = @related_policies.map { |d| d.policy_topics }.flatten.uniq
  end

  private

  def load_consultations_from_scope(scope)
    scope.published.includes(
      :document, :attachments, :published_consultation_response, :organisations
    ).sort_by { |c|
      [c.last_significantly_changed_on, c.first_published_at]
    }.reverse
  end

  def document_class
    Consultation
  end

  def scope_description
    params[:action] == 'index' ? 'All' : params[:action]
  end
end
