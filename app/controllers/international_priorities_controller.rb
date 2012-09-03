class InternationalPrioritiesController < DocumentsController
  def index
    @international_priorities = InternationalPriority.published.includes(:document).by_published_at
  end

  def show
  end

  private

  def document_class
    InternationalPriority
  end
end
