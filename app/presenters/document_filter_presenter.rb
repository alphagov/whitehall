class DocumentFilterPresenter < Draper::Base
  def as_json(options = nil)
    as_hash(options)
  end

  def as_hash(options = nil)
    data = {
      count: model.documents.count,
      current_page: model.documents.current_page,
      total_pages: model.documents.num_pages,
      total_count: model.documents.total_count,
      results: model.documents.map { |d| d.as_hash },
      results_any?: model.documents.any?
    }
    if !model.documents.last_page? || !model.documents.first_page?
      data[:more_pages?] = true
    end
    unless model.documents.last_page?
      data[:next_page?] = true
      data[:next_page] = model.documents.current_page + 1
      data[:next_page_url] = url(page: model.documents.current_page + 1)
      data[:next_page_json] = h.filter_json_url(page: model.documents.current_page + 1)
    end
    unless model.documents.first_page?
      data[:prev_page?] = true
      data[:prev_page] = model.documents.current_page - 1
      data[:prev_page_url] = url(page: model.documents.current_page - 1)
    end
    data
  end

  def url(override_params)
    h.url_for(h.params.merge(override_params).merge("_" => nil))
  end
end
