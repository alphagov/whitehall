class SearchRummagerService
  def fetch_related_documents(filter_params = {})
    options = default_search_options.merge(filter_params)
    search_response = Whitehall.search_client.search(options)
    search_response["results"].map! { |res| RummagerDocumentPresenter.new(res) }
    search_response
  end

  private

  def default_search_options
    {
      order: "-public_timestamp",
      count: 1000,
      fields: %w[display_type title link public_timestamp format content_store_document_type
                 description content_id organisations document_collections]
    }
  end
end
