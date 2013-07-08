module DocumentFilterHelper
  def classification_filter_options(selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    grouped_classifications = [
      [ 'Topics', Topic.alphabetical.map { |o| [o.name, o.slug] } ],
      [ 'Topical events', TopicalEvent.active
                                      .order_by_start_date.map { |o| [o.name, o.slug] } ]
    ]
    options_for_select([["All topics", "all"]], selected_values) +
    grouped_options_for_select(grouped_classifications, selected_values)
  end

  def organisation_filter_options(organisations, selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    grouped_organisations = {
      'Ministerial departments' =>  organisations.with_translations
                                    .ministerial_departments
                                    .ordered_by_name_ignoring_prefix
                                    .map { |o| [o.name, o.slug] },

      'Other departments & public bodies' =>  organisations
                                              .with_translations
                                              .non_ministerial_departments
                                              .ordered_by_name_ignoring_prefix
                                              .map { |o| [o.name, o.slug] }
    }
    options_for_select([["All departments", "all"]], selected_values) +
    grouped_options_for_select(grouped_organisations, selected_values)
  end

  def publication_type_filter_options(publication_filter_options, selected_publication_filter_options = nil)
    selected_value = selected_publication_filter_options ? selected_publication_filter_options.slug : "all"

    options_with_group_key = publication_filter_options.select { |a| a.group_key.present? }
    grouped_options = options_with_group_key.group_by(&:group_key)
    publication_filter_options.reject! { |a| a.group_key.present? }
    options_for_select([["All publication types", "all"]], [selected_value]) +
    grouped_options_for_select(grouped_options.map { |a| [a[0].titleize, a[1].map { |pt| [pt.label, pt.slug] }]}, [selected_value]) +
    options_for_select(publication_filter_options.sort_by { |a| a.label }.map { |pt| [pt.label, pt.slug] }, [selected_value])
  end

  def announcement_type_filter_options(announcement_filter_options, selected_announcement_filter_options = nil)
    selected_value = selected_announcement_filter_options ? selected_announcement_filter_options.slug : "all"
    options_for_select([["All announcement types", "all"]] +
    announcement_filter_options.sort_by { |a| a.label }.map { |a| [a.label, a.slug] }, [selected_value])
  end

  def people_filter_options(people, selected_person = nil)
    selected_value = selected_person ? selected_person : "all"
    options_for_select([["All ministers", "all"]] +
    people.map{ |a| [a.name, a.slug] }, [selected_value])
  end

  def locations_options(locations, selected_locations)
    selected_value = selected_locations.any? ? selected_locations.map(&:slug) : ["all"]
    options_for_select([[t("document_filters.world_locations.all"), "all"]] +
    locations.map { |a| [a.name, a.slug] }, selected_value)
  end

  def all_locations_with(type)
    case type
    when :announcement
      WorldLocation.with_announcements.ordered_by_name
    when :publication
      WorldLocation.with_publications.ordered_by_name
    end
  end

  def all_organisations_with(type)
    case type
    when :publication
      Organisation.with_published_editions(:publicationesque)
    else
      Organisation.with_published_editions(type)
    end
  end

  def publication_types_for_filter
    Whitehall::PublicationFilterOption.all
  end

  def announcement_types_for_filter
    Whitehall::AnnouncementFilterOption.all
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
    results = keywords.map.with_index do |word, index|
      new_keywords = keywords.reject.with_index { |w, i| i == index }.join(' ')
      {
        name: word,
        url: url_for(remove_filter_from_params('keywords').merge({ 'keywords' => new_keywords }))
      }
    end
    results.map.with_index { |obj, i| obj.merge({ joining: (results.length - 1 == i ? '' : 'or') }) }
  end

  def result_count(count)
    if count > 0
      "Showing #{pluralize(count, 'result')}"
    else
      "No results"
    end
  end
end
