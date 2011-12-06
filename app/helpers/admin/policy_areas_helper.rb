module Admin::PolicyAreasHelper
  def policy_area_css_classes(policy_area)
    result = ''
    result << ' featured' if policy_area.featured?
  end

  def documents_preventing_destruction(policy_area)
    policy_area.policies.map do |d|
      [link_to(d.title, admin_document_path(d)),
       content_tag(:span,
                   %{(#{d.state} #{d.class.name.underscore.humanize.downcase})},
                   class: "document_state")
      ].join(" ")
    end.to_sentence.html_safe
  end
end