module Admin::DocumentsHelper
  def nested_attribute_destroy_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_documents_path, /^\/admin\/(documents|publications|policies|news_articles|consultations|speeches)/
  end

  def admin_policy_areas_header_link
    admin_header_link "Policy Areas", admin_topics_path
  end

  def admin_organisations_header_link
    admin_header_link "Organisations", admin_organisations_path
  end

  def admin_roles_header_link
    admin_header_link "Roles", admin_roles_path
  end

  def admin_people_header_link
    admin_header_link "People", admin_people_path
  end

  def admin_header_link(name, path, path_matcher = nil)
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if logged_in?
      link_to name, path, class: current_link_class(path_matcher)
    end
  end

  def link_to_filter(link, options)
    link_to link, url_for(params.slice('filter', 'author', 'organisation').merge(options)), class: filter_class(options)
  end

  def filter_class(options)
    current = options.keys.all? do |key|
      options[key].to_param == params[key].to_param
    end

    'current' if current
  end

  def humanized_content_type(content_type)
    content_type.present? && content_type.split("/").last.upcase
  end

  def order_link(document)
    return "" unless document.order_url.present?
    link_to document.order_url, document.order_url, class: "order_url"
  end
end