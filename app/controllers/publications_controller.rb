class PublicationsController < DocumentsController
  def index
    all_publications
    featured_publications
    other_publications
  end

  def show
    @related_policies = @document.published_related_policies
    @policy_topics = @related_policies.map { |d| d.policy_topics }.flatten.uniq
  end

  private

  def all_publications
    @all_publications ||= Publication.published_in_reverse_chronological_order.includes(:document_identity)
  end

  def featured_publications
    @featured_publications ||= all_publications.select(&:featured)[0..3]
  end

  def other_publications
    @other_publications ||= (all_publications - featured_publications)
  end

  def document_class
    Publication
  end
end
