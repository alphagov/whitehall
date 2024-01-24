module SearchApiHelper
  def search_api_response
    File.read(Rails.root.join("features/fixtures/search_api_response.json"))
  end

  def processed_search_api_documents
    ActiveSupport::JSON.decode(search_api_response)["results"].map! do |res|
      SearchApiDocumentPresenter.new(res)
    end
  end

  def search_api_service_stub(search_params)
    results = {}
    results["results"] = processed_search_api_documents

    SearchApiService
      .any_instance
      .expects(:fetch_related_documents)
      .with(search_params)
      .returns(results)
  end

  def attributes(documents_object)
    documents_object.map do |document|
      [
        document.title,
        document.link,
        document.summary,
        document.content_id,
        document.publication_collections,
        document.publication_date,
      ]
    end
  end
end
