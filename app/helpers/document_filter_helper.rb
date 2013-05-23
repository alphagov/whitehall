module DocumentFilterHelper
  def topic_filter_options(topics, selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    options_for_select([["All topics", "all"]] + topics.map { |o| [o.name, o.slug] }, selected_values)
  end

  def organisation_filter_options(organisations, selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    grouped_organisations = {
      'Ministerial departments' => organisations.ministerial_departments.ordered_by_name_ignoring_prefix.map { |o| [o.name, o.slug] },
      'Other departments & public bodies' => organisations.non_ministerial_departments.ordered_by_name_ignoring_prefix.map { |o| [o.name, o.slug] }
    }
    options_for_select([["All departments", "all"]], selected_values) + grouped_options_for_select(grouped_organisations, selected_values)
  end

  def publication_type_filter_options(publication_filter_options, selected_publication_filter_options = nil)
    selected_value = selected_publication_filter_options ? selected_publication_filter_options.slug : "all"
    options_for_select([["All publication types", "all"]] + publication_filter_options.sort_by { |a| a.label }.map { |pt| [pt.label, pt.slug] }, [selected_value])
  end

  def announcement_type_filter_options(announcement_filter_options, selected_announcement_filter_options = nil)
    selected_value = selected_announcement_filter_options ? selected_announcement_filter_options.slug : "all"
    options_for_select([["All announcement types", "all"]] + announcement_filter_options.sort_by { |a| a.label }.map { |a| [a.label, a.slug] }, [selected_value])
  end

  def people_filter_options(people, selected_person = nil)
    selected_value = selected_person ? selected_person : "all"
    options_for_select([["All ministers", "all"]] + people.map{ |a| [a.name, a.slug] }, [selected_value])
  end

  def consultation_type_filter_options(selected_consultation_type)
    selected_value = selected_consultation_type ? selected_consultation_type : "all"
    types = ["Consultation outcome","Closed consultation","Open consultation"]
    options_for_select([["All consultation types", "all"]] + types.map{ |a|[a, a] }, [selected_value])
  end

  def locations_options(locations, selected_locations)
    selected_value = selected_locations.any? ? selected_locations.map(&:slug) : ["all"]
    options_for_select([[t("document_filters.world_locations.all"), "all"]] + locations.map { |a|[a.name, a.slug] }, selected_value)
  end

  def all_topics_with(type)
    case type
    when :publication
      Topic.with_related_publications.sort_by(&:name)
    when :detailed_guide
      Topic.with_related_detailed_guides.order(:name)
    when :announcement
      Topic.with_related_announcements.order(:name)
    when :policy
      Topic.with_related_policies.order(:name)
    end
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
    Organisation.joins(:"published_#{type.to_s.pluralize}").group('organisation_translations.name').includes(:translations)
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
