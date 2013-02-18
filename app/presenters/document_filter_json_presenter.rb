class DocumentFilterJsonPresenter < Draper::Base
  def as_json(options = nil)
    data = {
      count: model.documents.count,
      current_page: model.documents.current_page,
      total_pages: model.documents.num_pages,
      total_count: model.documents.total_count,
      results: model.documents.map { |d| document_hash(d) }
    }
    unless model.documents.last_page?
      data[:next_page] = model.documents.current_page + 1
      data[:next_page_url] = url(page: model.documents.current_page + 1)
    end
    unless model.documents.first_page?
      data[:prev_page] = model.documents.current_page - 1
      data[:prev_page_url] = url(page: model.documents.current_page - 1)
    end
    data
  end

  def url(override_params)
    h.url_for(h.params.merge(override_params).merge("_" => nil))
  end

  def document_hash(document)
    {
      id: document.id,
      type: document.type.underscore,
      title: document.title,
      url: h.public_document_path(document),
      organisations: document.organisations.map { |o|
        h.organisation_display_name(o)
      }.to_sentence.html_safe,
      public_timestamp: document.public_timestamp
    }
  end
end
