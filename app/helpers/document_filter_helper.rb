module DocumentFilterHelper
  def topic_filter_options(topics, selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    options_for_select([["All topics", "all"]] + topics.map{ |o| [o.name, o.slug] }, selected_values)
  end

  def organisation_filter_options(organisations, selected_organisations = [])
    selected_values = selected_organisations.any? ? selected_organisations.map(&:slug) : ["all"]
    options_for_select([["All departments", "all"]] + organisations.map{ |o| [o.name, o.slug] }, selected_values)
  end

  def publication_type_filter_options(publication_filter_options, selected_publication_filter_options = nil)
    selected_value = selected_publication_filter_options ? selected_publication_filter_options.slug : "all"
    options_for_select([["All publication types", "all"]] + publication_filter_options.map{ |pt| [pt.label, pt.slug] }, [selected_value])
  end

  def announcement_type_filter_options(announcement_filter_options, selected_announcement_filter_options = nil)
    selected_value = selected_announcement_filter_options ? selected_announcement_filter_options : "all"
    options_for_select([["All announcement types", "all"]] + announcement_filter_options.map{ |a| [a.tableize.humanize, a] }, [selected_value])
  end
end
