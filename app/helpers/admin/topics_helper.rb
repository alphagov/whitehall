module Admin::TopicsHelper
  def policies_preventing_destruction(topic)
    topic.policies.map do |d|
      link_to(d.title, admin_edition_path(d)) + " " +
      content_tag(:span,
                   %{(#{d.state} #{d.format_name})},
                   class: "document_state")
    end
  end
end
