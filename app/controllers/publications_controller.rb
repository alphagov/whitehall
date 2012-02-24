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
    @featured_publications ||= begin
      all_featured = all_publications.select(&:featured)
      only_multiples_of_two(all_featured[0..3])
    end
  end

  def other_publications
    @other_publications ||= (all_publications - featured_publications)
  end

  def only_multiples_of_two(list)
    range = Range.new(0, (list.size/2) * 2 - 1)
    list[range]
  end

  def document_class
    Publication
  end
end
