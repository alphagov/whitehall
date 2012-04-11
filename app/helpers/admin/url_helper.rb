module Admin::UrlHelper
  def admin_policy_topics_header_link
    admin_header_link "Policy topics", admin_policy_topics_path
  end

  def admin_organisations_header_link
    admin_header_link "Departments & agencies", admin_organisations_path
  end

  def admin_roles_header_link
    admin_header_link "Roles", admin_roles_path
  end

  def admin_people_header_link
    admin_header_link "People", admin_people_path
  end

  def admin_countries_header_link
    admin_header_link "Countries", admin_countries_path
  end

  def admin_header_link(name, path, path_matcher = nil)
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if user_signed_in?
      link_to name, path, class: current_link_class(path_matcher)
    end
  end

  def website_home_url
    if host = Whitehall.public_host_for(request.host)
      "http://#{host}/government/home"
    else
      home_path
    end
  end
end
