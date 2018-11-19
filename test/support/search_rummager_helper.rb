module SearchRummagerHelper
  def rummager_response
    File.read(Rails.root.join('features/fixtures/rummager_response.json'))
  end

  def processed_rummager_documents
    ActiveSupport::JSON.decode(rummager_response)['results'].map! { |res|
      RummagerDocumentPresenter.new(res)
    }
  end

  def search_rummager_service_stub(search_params)
    results = {}
    results['results'] = processed_rummager_documents

    SearchRummagerService
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
        document.publication_date
      ]
    end
  end
end
