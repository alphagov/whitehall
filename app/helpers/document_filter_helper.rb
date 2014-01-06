module DocumentFilterHelper
  def topic_filter_options(selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    options_for_select([filter_options.for(:topics).all], selected_values) +
    unsorted_grouped_options_for_select(filter_options.for(:topics).grouped, selected_values)
  end

  def organisation_filter_options(selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    options_for_select([filter_options.for(:organisations).all], selected_values) +
    unsorted_grouped_options_for_select(filter_options.for(:organisations).grouped, selected_values)
  end

  def publication_type_filter_options(selected_publication_filter_option = nil)
    selected_value = selected_publication_filter_option ? selected_publication_filter_option.slug : "all"
    filter_option_html(filter_options.for(:publication_type), selected_value)
  end

  def announcement_type_filter_options(selected_announcement_filter_option = nil)
    selected_value = selected_announcement_filter_option ? selected_announcement_filter_option.slug : "all"
    filter_option_html(filter_options.for(:announcement_type), selected_value)
  end

  def locations_options(document_type, selected_locations = [])
    selected_values = selected_locations.any? ? selected_locations.map(&:slug) : ["all"]
    filter_option_html(filter_options.for(:locations), selected_values)
  end

  def official_document_status_filter_options(selected = nil)
    filter_option_html(filter_options.for(:official_documents), selected.to_s)
  end

  def remove_filter_from_params(key, value = nil)
    if value && params[key].is_a?(Array)
      params.merge({ key => (params[key] - [value]) })
    else
      params.merge({ key => nil })
    end
  end

  def filter_results_selections(objects, type)
    results = objects.map do |obj|
      {
        name: obj.name,
        url: url_for(remove_filter_from_params(type, obj.slug)),
        value: obj.slug
      }
    end
    results.map.with_index { |obj, i| obj.merge({ joining: (results.length - 1 == i ? '' : 'and') }) }
  end

  def filter_results_keywords(keywords)
    if keywords.any?
      {
        name: keywords.join(' '),
        url: url_for(remove_filter_from_params('keywords'))
      }
    end
  end

protected

  def filter_options
    @filter_options ||= Whitehall::DocumentFilter::Options.new
  end

  def filter_option_html(options, selected_value)
    selected_values = Array(selected_value)
    options_for_select([options.all], selected_values) +
    grouped_options_for_select(options.grouped, selected_values) +
    options_for_select(options.ungrouped, selected_values)
  end
end
