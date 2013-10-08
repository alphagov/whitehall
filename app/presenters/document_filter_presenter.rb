class DocumentFilterPresenter < Struct.new(:filter, :context, :document_decorator)
  extend Whitehall::Decorators::DelegateInstanceMethodsOf
  delegate_instance_methods_of Whitehall::DocumentFilter::Filterer, to: :filter

  def as_json(options = nil)
    as_hash(options)
  end

  def as_hash(options = nil)
    data = {
      count: documents.count,
      current_page: documents.current_page,
      total_pages: documents.total_pages,
      total_count: documents.total_count,
      results: documents.map { |d| d.as_hash },
      results_any?: documents.any?,
      no_results_title: context.t('document_filters.no_results.title'),
      no_results_description: context.t('document_filters.no_results.description'),
      no_results_tna_heading: context.t('document_filters.no_results.tna_heading'),
      no_results_tna_link: context.t('document_filters.no_results.tna_link')
    }
    if !documents.last_page? || !documents.first_page?
      data[:more_pages?] = true
    end
    unless documents.last_page?
      data[:next_page?] = true
      data[:next_page] = documents.current_page + 1
      data[:next_page_url] = url(page: documents.current_page + 1)
    end
    unless documents.first_page?
      data[:prev_page?] = true
      data[:prev_page] = documents.current_page - 1
      data[:prev_page_url] = url(page: documents.current_page - 1)
    end
    data
  end

  def url(override_params)
    context.url_for(context.params.merge(override_params).merge("_" => nil).except(:format))
  end

  def date_from
    from_date ? from_date.to_s(:uk_short) : nil
  end

  def date_to
    to_date ? to_date.to_s(:uk_short) : nil
  end

  def documents
    if document_decorator
      Whitehall::Decorators::CollectionDecorator.new(
        filter.documents, document_decorator, context)
    else
      filter.documents
    end
  end
end
