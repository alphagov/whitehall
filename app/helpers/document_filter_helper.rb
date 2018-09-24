module DocumentFilterHelper
  def taxon_filter_options(selected_taxons = [])
    selected_value = selected_taxons.any? ? selected_taxons : %w[all]
    filter_option_html(filter_options.for(:taxons), selected_value)
  end

  def subtaxon_filter_options(selected_taxons = [], selected_subtaxons = [])
    filter_option_html(
      filter_options.for(:subtaxons, selected_taxons),
      selected_subtaxons
    )
  end

  def topic_filter_options(selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : %w[all]
    options_for_select([filter_options.for(:topics).all], selected_values) +
      unsorted_grouped_options_for_select(filter_options.for(:topics).grouped, selected_values)
  end

  def organisation_filter_options(selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : %w[all]
    options_for_select([filter_options.for(:organisations).all], selected_values) +
      unsorted_grouped_options_for_select(filter_options.for(:organisations).grouped, selected_values)
  end

  def people_filter_options(selected_people = [])
    selected_value = selected_people ? selected_people.map(&:slug) : %w[all]
    filter_option_html(filter_options.for(:people), selected_value)
  end

  def publication_type_filter_options(selected_publication_filter_option = nil)
    selected_value = selected_publication_filter_option ? selected_publication_filter_option.slug : "all"
    filter_option_html(filter_options.for(:publication_type), selected_value)
  end

  def announcement_type_filter_options(selected_announcement_filter_option = nil)
    selected_value = selected_announcement_filter_option ? selected_announcement_filter_option.slug : "all"
    filter_option_html(filter_options.for(:announcement_type), selected_value)
  end

  def locations_options(_document_type, selected_locations = [])
    selected_values = selected_locations.any? ? selected_locations.map(&:slug) : %w[all]
    filter_option_html(filter_options.for(:locations), selected_values)
  end

  def official_document_status_filter_options(selected = nil)
    filter_option_html(filter_options.for(:official_documents), selected.to_s)
  end

  def remove_filter_from_params(key, value = nil)
    if value && params[key].is_a?(Array)
      params.merge(key => (params[key] - [value]))
    else
      params.merge(key => nil)
    end
  end

  def filter_taxon_selections(taxon_content_ids, subtaxon_content_ids)
    options_for_taxons = Taxonomy::TopicTaxonomy
                           .new
                           .ordered_taxons
                           .map do |level_one_taxon|

      if taxon_content_ids.include? level_one_taxon.content_id
        subtaxon_content_ids_without_all = subtaxon_content_ids - %w[all]

        if subtaxon_content_ids_without_all.empty?
          {
            name: level_one_taxon.name,
            value: level_one_taxon.content_id,
            url: url_for(
              remove_filter_from_params(
                'taxons',
                level_one_taxon.content_id
              )
            )
          }
        else
          filtered_child_taxons = level_one_taxon
                                    .children
                                    .select do |taxon|

            subtaxon_content_ids.include? taxon.content_id
          end

          filtered_child_taxons.map do |child_taxon|
            {
              name: child_taxon.name,
              value: child_taxon.content_id,
              url: url_for(
                remove_filter_from_params(
                  'subtaxons',
                  child_taxon.content_id
                )
              )
            }
          end
        end
      else
        []
      end
    end

    merge_joining_option(options_for_taxons.flatten)
  end

  def filter_results_selections(objects, type)
    results = objects.map do |obj|
      {
        name: obj.name,
        url: url_for(remove_filter_from_params(type, obj.slug)),
        value: obj.slug
      }
    end
    merge_joining_option(results)
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

  def merge_joining_option(results)
    results.map.with_index { |obj, i| obj.merge(joining: (results.length - 1 == i ? '' : 'and')) }
  end

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
