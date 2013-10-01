module TopicsHelper
  def array_of_links_to_topics(topics)
    topics.map { |topic|
      link_to topic.name, topic_path(topic)
    }
  end

  def array_of_links_to_topical_events(topical_events)
    topical_events.map { |topical_event|
      link_to topical_event.name, topical_event_path(topical_event)
    }
  end

  def classification_contents_breakdown(classification)
    capture do
      concat content_tag(:span, pluralize(classification.policies.published.count, "published policy"))
      concat content_tag(:span, pluralize(classification.detailed_guides.published.count, "published detailed guide"))
    end
  end

  def topic_grid_size_class(*edition_scopes)
    "grid-size-#{edition_scopes.compact.select(&:any?).length}"
  end
end
