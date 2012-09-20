module DocumentFilterHelper
  def topic_filter_options(topics, selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    options_for_select([["All topics", "all"]] + topics.map{ |o| [o.name, o.slug] }, selected_values)
  end

  def organisation_filter_options(organisations, selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    options_for_select([["All departments", "all"]] + organisations.map{ |o| [o.name, o.slug] }, selected_values)
  end

  def publication_type_filter_options(publication_types, selected_publication_type = nil)
    selected_value = selected_publication_type ? selected_publication_type.slug : "all"
    options_for_select([["All publication types", "all"]] + publication_types.map{ |pt| [pt.plural_name, pt.slug] }, [selected_value])
  end
end
