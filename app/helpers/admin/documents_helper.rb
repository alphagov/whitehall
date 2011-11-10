module Admin::DocumentsHelper
  def nested_attribute_destroy_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_documents_path, /^\/admin\/(documents|publications|policies|news_articles|consultations|speeches)/
  end

  def admin_topics_header_link
    admin_header_link "Topics", admin_topics_path
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
      link_to name, path, class: header_link_class(path_matcher)
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

  def header_link_class(path_matcher)
    'current' if request.path =~ path_matcher
  end
end