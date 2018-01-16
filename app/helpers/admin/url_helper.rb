module Admin::UrlHelper
  def admin_user_organisation_header_link
    if user_signed_in? && (organisation = current_user.organisation)
      admin_header_link 'Corporate information', admin_organisation_corporate_information_pages_path(organisation)
    end
  end

  def admin_statistics_announcements_link
    admin_header_link "Statistics announcements", admin_statistics_announcements_path
  end

  def admin_topics_header_menu_link
    admin_header_menu_link "Policy Areas", admin_topics_path
  end

  def admin_featured_header_link
    if user_signed_in? && (organisation = current_user.organisation)
      admin_header_link "Featured documents", features_admin_organisation_path(organisation, locale: nil)
    end
  end

  def admin_topical_events_header_menu_link
    admin_header_menu_link "Topical events", admin_topical_events_path
  end

  def admin_organisations_header_menu_link
    admin_header_menu_link "Departments & agencies", admin_organisations_path
  end

  def admin_roles_header_menu_link
    admin_header_menu_link "Roles", admin_roles_path
  end

  def admin_people_header_menu_link
    admin_header_menu_link "People", admin_people_path
  end

  def admin_worldwide_organisations_header_menu_link
    admin_header_menu_link "Worldwide organisations", admin_worldwide_organisations_path
  end

  def admin_world_locations_header_menu_link
    admin_header_menu_link "World location news", admin_world_locations_path
  end

  def admin_policy_groups_header_menu_link
    admin_header_menu_link "Groups", admin_policy_groups_path
  end

  def admin_users_header_link
    content_tag(:li, link_to("All users", admin_users_path))
  end

  def admin_fields_of_operation_header_menu_link
    if current_user && current_user.can_handle_fatalities?
      admin_header_menu_link "Fields of operation", admin_operational_fields_path
    end
  end

  def admin_cabinet_ministers_header_menu_link
    admin_header_menu_link "Cabinet ministers order", admin_cabinet_ministers_path
  end

  def admin_get_involved_header_menu_link
    if can?(:administer, :get_involved_section)
      admin_header_menu_link "Get involved", admin_get_involved_path
    end
  end

  def admin_sitewide_settings_header_menu_link
    if can?(:administer, :sitewide_settings_section)
      admin_header_menu_link "Sitewide settings", admin_sitewide_settings_path
    end
  end

  def admin_governments_header_menu_link
    admin_header_menu_link "Governments", admin_governments_path
  end

  def admin_header_menu_link(name, path)
    content_tag(:li, link_to(name, path, role: 'menuitem'), class: 'masthead-menu-item')
  end

  def admin_header_link(name, path, path_matcher = nil, options = {})
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if user_signed_in?
      li_class = active_link_class(path_matcher)
      if options[:class]
        li_class = [li_class, options[:class]].join(' ')
      end
      content_tag(:li, link_to(name, path), class: "masthead-tab-item #{li_class}")
    end
  end

  def active_link_class(path_matcher)
    request.path.match?(path_matcher) ? 'active' : ''
  end
end
