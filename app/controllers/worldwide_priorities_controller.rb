class WorldwidePrioritiesController < DocumentsController
  def index
    @worldwide_priorities = WorldwidePriority.published.includes(:document, :translations).in_reverse_chronological_order
  end

  def show
  end

  private

  def document_class
    WorldwidePriority
  end
end
