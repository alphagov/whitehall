module TopicsHelper
  def list_of_links_to_topics(topics)
    topics.map { |topic| link_to topic.name, topic_path(topic), class: "topic", id: "topic_#{topic.id}" }.to_sentence.html_safe
  end

  def classification_contents_breakdown(classification)
    [
      pluralize(classification.policies.published.count, "published policy"),
      pluralize(classification.detailed_guides.published.count, "published detailed guide")
    ].to_sentence
  end
end
