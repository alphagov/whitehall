class InternationalPrioritiesController < DocumentsController
  def index
    @international_priorities = InternationalPriority.published.includes(:document).in_reverse_chronological_order
  end

  def show
  end

  private

  def document_class
    InternationalPriority
  end
end
