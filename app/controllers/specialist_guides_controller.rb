class SpecialistGuidesController < DocumentsController
  layout "specialist"

  def index
    @topics_and_published_specialist_guides = Topic.joins(:published_specialist_guides).includes(:published_specialist_guides)
  end

  def show
    @topics = @document.topics
  end

private
  def document_class
    SpecialistGuide
  end
end
