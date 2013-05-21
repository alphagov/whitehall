module TopicsHelper
  def list_of_links_to_topics(topics)
    topics.map { |topic|
      link_to topic.name,
              topic_path(topic),
              class: "topic",
              id: dom_id(topic)
    }.to_sentence.html_safe
  end

  def list_of_links_to_topical_events(topical_events)
    topical_events.map { |topical_event|
      link_to topical_event.name,
              topical_event_path(topical_event),
              class: "topic topical_event",
              id: dom_id(topical_event)
    }.to_sentence.html_safe
  end
end
