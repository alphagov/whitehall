class InternationalPrioritiesController < DocumentsController
  def index
    @international_priorities = InternationalPriority.published
  end

  def show
  end

  private

  def document_class
    InternationalPriority
  end
end
