module DocumentFilterHelper
  def classification_filter_options(selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    grouped_classifications = Rails.cache.fetch("classification_filter_options/grouped_classifications", expires_in: 30.minutes) do
      [
        [ 'Topics', Topic.alphabetical.map { |o| [o.name, o.slug] } ],
        [ 'Topical events', TopicalEvent.active
                                        .order_by_start_date.map { |o| [o.name, o.slug] } ]
      ]
    end
    options_for_select([["All topics", "all"]], selected_values) +
    grouped_options_for_select(grouped_classifications, selected_values)
  end

  def organisation_filter_options(selected_organisations = [])
    grouped_organisation_options = Rails.cache.fetch("organisation_filter_options/grouped_organisations/#{I18n.locale}", expires_in: 30.minutes) do
       {
        'Ministerial departments' =>  Organisation.with_published_editions
                                      .excluding_govuk_status_closed
                                      .with_translations
                                      .ministerial_departments
                                      .ordered_by_name_ignoring_prefix
                                      .map { |o| [o.name, o.slug] },

        'Other departments & public bodies' =>  Organisation.with_published_editions
                                                .excluding_govuk_status_closed
                                                .with_translations
                                                .excluding_ministerial_departments
                                                .ordered_by_name_ignoring_prefix
                                                .map { |o| [o.name, o.slug] },

        'Closed organisations' => Organisation.with_published_editions
                                                .closed
                                                .with_translations
                                                .ordered_by_name_ignoring_prefix
                                                .map { |o| [o.name, o.slug] }
      }
    end
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    options_for_select([["All departments", "all"]], selected_values) +
    unsorted_grouped_options_for_select(grouped_organisation_options, selected_values)
  end

  def publication_type_filter_options(publication_filter_options, selected_publication_filter_options = nil)
    selected_value = selected_publication_filter_options ? selected_publication_filter_options.slug : "all"

    options_with_group_key = publication_filter_options.select { |a| a.group_key.present? }
    grouped_options = options_with_group_key.group_by(&:group_key)
    publication_filter_options.reject! { |a| a.group_key.present? }
    options_for_select([["All publication types", "all"]], [selected_value]) +
    grouped_options_for_select(grouped_options.map { |a| [a[0], a[1].map { |pt| [pt.label, pt.slug] }]}, [selected_value]) +
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

  def locations_options(document_type, selected_locations)
    selected_value = selected_locations.any? ? selected_locations.map(&:slug) : ["all"]
    locations = Rails.cache.fetch("locations_options/locations/#{document_type}/#{I18n.locale}", expires_in: 30.minutes) do
      edition_constraint = case document_type
      when :announcement then :with_announcements
      when :publication then :with_publications
      else
        raise "unsupported document type for WorldLocation filter options"
      end

      [[t("document_filters.world_locations.all"), "all"]] +
        WorldLocation.send(edition_constraint)
          .includes(:translations)
          .ordered_by_name
          .map { |a| [a.name, a.slug] }
    end
    options_for_select(locations, selected_value)
  end

  def official_document_status_filter_options(selected = nil)
    options_for_select([
      ['All documents', 'all'],
      ['Command or act papers', 'command_and_act_papers'],
      ['Command papers only', 'command_papers_only'],
      ['Act papers only', 'act_papers_only']
    ], selected.to_s)
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

  def result_type(count)
    "result".pluralize(count)
  end
end
