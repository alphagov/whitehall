class CaseStudiesController < DocumentsController
  def index
    @case_studies = CaseStudy.published.includes(:document, :translations).in_reverse_chronological_order
  end

  def show
    @related_policies = @document.published_related_policies
    @document = CaseStudyPresenter.new(@document, view_context)
    set_slimmer_headers_for_document(@document)
  end

  private

  def document_class
    CaseStudy
  end
end
