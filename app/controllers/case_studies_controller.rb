class CaseStudiesController < DocumentsController
  def index
    @case_studies = CaseStudy.published.includes(:document).by_published_at
  end

  def show
    @related_policies = @document.published_related_policies
  end

  private

  def document_class
    CaseStudy
  end
end
