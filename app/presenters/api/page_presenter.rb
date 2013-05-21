class Api::PagePresenter < Struct.new(:page, :context)

  def as_json(options = {})
    {
      results: page.map(&:as_json),
      previous_page_url: previous_page_url,
      next_page_url: next_page_url,
      current_page: page.current_page,
      total: page.total_count,
      pages: page.num_pages,
      page_size: page.limit_value,
      start_index: start_index
    }.reject { |k, v| v.nil? }
  end

  def links
    links = []
    links << [previous_page_url, {'rel' => 'previous'}] if previous_page_url
    links << [next_page_url, {'rel' => 'next'}] if next_page_url
    links << [url(page: page.current_page), {'rel' => 'self'}]
    links
  end

  def previous_page_url
    unless page.first_page?
      url(page: page.current_page - 1)
    end
  end

  def next_page_url
    unless page.last_page?
      url(page: page.current_page + 1)
    end
  end

  def start_index
    # current_page and start_index start at 1, not 0
    (page.current_page - 1) * page.limit_value + 1
  end
  private

  def url(override_params)
    context.url_for(context.params.merge(
      override_params.merge(only_path: false)
    ))
  end
end
