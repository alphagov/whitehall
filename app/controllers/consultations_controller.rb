class ConsultationsController < DocumentsController
  def index
    query_params = {
      content_store_document_type: %w[
        open_consultations
        closed_consultations
      ],
    }

    query_params["level_one_taxon"] = params[:topics] if params[:topics]
    query_params["organisations"] = params[:departments] if params[:departments]

    redirect_to "/search/policy-papers-and-consultations?#{query_params.to_query}"
  end
end
