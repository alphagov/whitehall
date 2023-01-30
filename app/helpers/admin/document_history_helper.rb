module Admin::DocumentHistoryHelper
  def paginated_document_history_url(page:, editing: nil)
    url_for(
      params.to_unsafe_hash
            .merge(controller: "admin/edition_document_history", action: "index", page: (page <= 1 ? nil : page), editing:)
            .symbolize_keys,
    )
  end
end
