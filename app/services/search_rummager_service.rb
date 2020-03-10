class SearchRummagerService
  def fetch_related_documents(filter_params = {})
    search_params = default_search_params.merge(filter_params)
    Rails.cache.fetch(search_params, expires_in: 5.minutes) { search_results(search_params) }
  end

private

  def search_results(search_params)
    results = Whitehall.search_client.search(search_params)["results"]
    results.map! { |res| RummagerDocumentPresenter.new(res) }
  end

  def default_search_params
    {
      order: "-public_timestamp",
      count: 1000,
      fields: %w[display_type title link public_timestamp format content_store_document_type
                 description content_id organisations document_collections],
    }
  end
end
