class CaseStudiesController < DocumentsController
  def show
    @related_policies = document_related_policies
    @document = CaseStudyPresenter.new(@document, view_context)
  end

  private

  def document_class
    CaseStudy
  end
end
