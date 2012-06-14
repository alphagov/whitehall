class PublicationsController < DocumentsController
  before_filter :load_topics, only: [:index, :by_topic]

  def index
    @all_publications = all_publications
    @featured_publication = @all_publications.select(&:featured).first
  end

  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

  def by_topic
    @all_publications = all_publications.in_topic(@selected_topics)
    @featured_publications = []
    render :index
  end

  private

  def load_topics
    @all_topics = Topic.order(:name)
    @top_topics = @all_topics.exemplars
    @selected_topics = Topic.where(slug: (params[:topics] || "").split("+")).all
  end

  def all_publications
    Publication.published_in_reverse_chronological_order.includes(:document, :organisations, :attachments)
  end

  def document_class
    Publication
  end
end
