class CallForEvidenceController < DocumentsController
  def index
    filter_params = Whitehall::DocumentFilter::CleanedParams.new(
      params.except(:controller, :action, :format, :_, :host),
    ).to_h

    redirect_to publications_path(filter_params.merge(publication_filter_option: "call_for_evidences"))
  end
end
