module TopicsHelper
  def list_of_links_to_topics(topics)
    topics.map { |topic| link_to topic.name, topic_path(topic), class: "topic", id: "topic_#{topic.id}" }.to_sentence.html_safe
  end
end
