class WorldwidePrioritiesController < DocumentsController
  def index
    @worldwide_priorities = WorldwidePriority.published.includes(:document, :translations).in_reverse_chronological_order
  end

  def show
    @recent_world_location_news = @document.published_related_world_location_news.in_reverse_chronological_order.limit(3)
  end

  private

  def document_class
    WorldwidePriority
  end
end
