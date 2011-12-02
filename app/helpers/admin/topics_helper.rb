module Admin::TopicsHelper
  def topic_css_classes(topic)
    result = ''
    result << ' featured' if topic.featured?
  end

  def documents_preventing_destruction(topic)
    topic.documents.map do |d|
      [link_to(d.title, admin_document_path(d)),
       content_tag(:span,
                   %{(#{d.state} #{d.class.name.underscore.humanize.downcase})},
                   class: "document_state")
      ].join(" ")
    end.to_sentence.html_safe
  end
end