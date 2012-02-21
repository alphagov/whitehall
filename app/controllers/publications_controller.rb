class PublicationsController < DocumentsController
  def index
    @publications = Publication.published_in_reverse_chronological_order.includes(:document_identity)
  end

  def show
    @related_policies = @document.published_related_policies
    @policy_topics = @related_policies.map { |d| d.policy_topics }.flatten.uniq
  end

  private

  def document_class
    Publication
  end
end
