module Admin::TopicsHelper
  def topic_css_classes(topic)
    result = ''
    result << ' featured' if topic.featured?
  end

  def policies_preventing_destruction(topic)
    topic.policies.map do |d|
      link_to(d.title, admin_edition_path(d)) + " " +
      content_tag(:span,
                   %{(#{d.state} #{d.class.name.underscore.humanize.downcase})},
                   class: "document_state")
    end
  end

  def list_of_links_to_topics(topics)
    topics.map { |t| link_to t.name, topic_path(t) }.to_sentence.html_safe
  end
end
