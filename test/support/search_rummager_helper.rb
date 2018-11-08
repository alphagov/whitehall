module SearchRummagerHelper
  def rummager_response
    File.read(Rails.root.join('features/fixtures/rummager_response.json'))
  end

  def processed_rummager_documents
    ActiveSupport::JSON.decode(rummager_response)['results'].map! { |res|
      RummagerDocumentPresenter.new(res)
    }
  end

  def attributes(documents_object)
    documents_object.map do |document|
      [
        document.title,
        document.link,
        document.summary,
        document.content_id,
      ]
    end
  end
end
