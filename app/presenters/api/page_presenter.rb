class Api::PagePresenter < Draper::Base
  def initialize(page)
    super(page)
  end

  def as_json(options = {})
    {
      results: model.map(&:as_json),
      previous_page_url: previous_page_url,
      next_page_url: next_page_url,
      current_page: model.current_page,
      total: model.total_count,
      pages: model.num_pages,
      page_size: model.limit_value,
      start_index: start_index
    }.reject {|k, v| v.nil? }
  end

  def previous_page_url
    unless model.first_page?
      url(page: model.current_page - 1)
    end
  end

  def next_page_url
    unless model.last_page?
      url(page: model.current_page + 1)
    end
  end

  def start_index
    model.current_page * model.limit_value
  end
  private

  def url(override_params)
    h.url_for(h.params.merge(
      override_params.merge(only_path: false, host: h.public_host)
    ))
  end
end
