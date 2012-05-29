module Admin::PolicyTopicsHelper
  def policy_topic_css_classes(policy_topic)
    result = ''
    result << ' featured' if policy_topic.featured?
  end

  def policies_preventing_destruction(policy_topic)
    policy_topic.policies.map do |d|
      [link_to(d.title, admin_document_path(d)),
       content_tag(:span,
                   %{(#{d.state} #{d.class.name.underscore.humanize.downcase})},
                   class: "document_state")
      ].join(" ")
    end.to_sentence.html_safe
  end
end