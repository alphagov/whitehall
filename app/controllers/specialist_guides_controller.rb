class SpecialistGuidesController < DocumentsController
  def index
    @specialist_guides = SpecialistGuide.published
  end

private
  def document_class
    SpecialistGuide
  end
end
