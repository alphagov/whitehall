module TopicsHelper
  def part_of_topics_paragraph(topics)
    if topics.any?
      content_tag :p, "Part of ".html_safe + list_of_links_to_topics(@document.topics) + ".".html_safe, class: 'topics'
    end
  end

  def list_of_links_to_topics(topics)
    topics.map { |topic| link_to topic.name, topic_path(topic), class: "topic" }.to_sentence.html_safe
  end

  def topic_filter_options(topics, selected_topics = [])
    selected_values = selected_topics.any? ? selected_topics.map(&:slug) : ["all"]
    options_for_select([["All topics", "all"]] + topics.map{ |o| [o.name, o.slug] }, selected_values)
  end
end
