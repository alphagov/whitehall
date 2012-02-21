class ConsultationsController < DocumentsController
  helper_method :scope_description

  before_filter :load_featured_consultations, only: [:index, :open, :closed]

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

  def show
    @related_policies = @document.published_related_policies
    @policy_topics = @related_policies.map { |d| d.policy_topics }.flatten.uniq
  end

  private

  def base_scope
    Consultation
  end

  def load_consultations_from_scope(scope)
    @consultations = scope.published.includes(:document_identity, :organisations, :published_related_policies, :published_consultation_response, ministerial_roles: [:current_people, :organisations]).sort_by { |c| [c.last_significantly_changed_on, c.first_published_at] }.reverse
  end

  def document_class
    Consultation
  end

  def scope_description
    params[:action] == 'index' ? '' : ' ' + params[:action]
  end

  def load_featured_consultations
    @featured_consultations = Consultation.published.featured.by_published_at.includes(:document_identity).limit(3)
  end
end