module Admin::UrlHelper
  def admin_user_organisation_header_link
    if user_signed_in? && organisation = current_user.organisation
      admin_header_link 'Manage corporate information', admin_organisation_corporate_information_pages_path(organisation), nil, class: 'user-org'
    end
  end

  def admin_topics_header_link
    admin_header_link "Topics", admin_topics_path
  end

  def admin_featured_header_link
    if user_signed_in? && organisation = current_user.organisation
      admin_header_link "Feature documents", features_admin_organisation_path(organisation, locale: nil)
    end
  end

  def admin_topical_events_header_link
    admin_header_link "Topical events", admin_topical_events_path
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

  def admin_worldwide_organisations_header_link
    admin_header_link "Worldwide organisations", admin_worldwide_organisations_path
  end

  def admin_world_locations_header_link
    admin_header_link "World locations", admin_world_locations_path
  end

  def admin_policy_teams_header_link
    admin_header_link "Policy teams", admin_policy_teams_path
  end

  def admin_policy_advisory_groups_header_link
    admin_header_link "Policy advisory groups", admin_policy_advisory_groups_path
  end

  def admin_imports_header_link
    if current_user && current_user.can_import?
      admin_header_link "Import", admin_imports_path
    end
  end

  def admin_users_header_link
    admin_header_link "All users", admin_users_path
  end

  def admin_fields_of_operation_header_link
    if current_user && current_user.can_handle_fatalities?
      admin_header_link "Fields of operation", admin_operational_fields_path
    end
  end

  def admin_cabinet_ministers_link
    admin_header_link "Sort Cabinet ministers", admin_cabinet_ministers_path
  end

  def admin_get_involved_link
    if can?(:administer, :get_involved_section)
      admin_header_link "Get involved", admin_get_involved_path
    end
  end

  def admin_header_link(name, path, path_matcher = nil, options = {})
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if user_signed_in?
      li_class = active_link_class(path_matcher)
      if options[:class]
        li_class = [li_class, options[:class]].join(' ')
      end
      content_tag(:li, link_to(name, path), class: li_class)
    end
  end

  def active_link_class(path_matcher)
    request.path =~ path_matcher ? 'active' : ''
  end

  def website_home_url
    root_url(host: public_host)
  end
end
