class DocumentFilterPresenter < Struct.new(:filter, :context)
  extend Whitehall::Decorators::DelegateInstanceMethodsOf
  delegate_instance_methods_of Whitehall::DocumentFilter::Filterer, to: :filter

  def as_json(options = nil)
    as_hash(options)
  end

  def as_hash(options = nil)
    data = {
      count: filter.documents.count,
      current_page: filter.documents.current_page,
      total_pages: filter.documents.total_pages,
      total_count: filter.documents.total_count,
      results: filter.documents.map { |d| d.as_hash },
      results_any?: filter.documents.any?,
      no_results_title: context.t('document_filters.no_results.title'),
      no_results_description: context.t('document_filters.no_results.description'),
      no_results_tna_heading: context.t('document_filters.no_results.tna_heading'),
      no_results_tna_link: context.t('document_filters.no_results.tna_link')
    }
    if !filter.documents.last_page? || !filter.documents.first_page?
      data[:more_pages?] = true
    end
    unless filter.documents.last_page?
      data[:next_page?] = true
      data[:next_page] = filter.documents.current_page + 1
      data[:next_page_url] = url(page: filter.documents.current_page + 1)
      data[:next_page_json] = context.filter_json_url(page: filter.documents.current_page + 1)
    end
    unless filter.documents.first_page?
      data[:prev_page?] = true
      data[:prev_page] = filter.documents.current_page - 1
      data[:prev_page_url] = url(page: filter.documents.current_page - 1)
    end
    data
  end

  def url(override_params)
    context.url_for(context.params.merge(override_params).merge("_" => nil))
  end
end
