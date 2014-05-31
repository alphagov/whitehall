module Admin::UrlHelper
  def admin_user_organisation_header_link
    if user_signed_in? && organisation = current_user.organisation
      admin_header_link 'Corporate information', admin_organisation_corporate_information_pages_path(organisation), nil, class: 'user-org'
    end
  end

  def admin_statistics_announcements_link
    if user_can_see_stats_announcements?
      admin_header_link "Statistics announcements", admin_statistics_announcements_path
    end
  end

  def admin_topics_header_link
    admin_header_link "Topics", admin_topics_path
  end

  def admin_featured_header_link
    if user_signed_in? && organisation = current_user.organisation
      admin_header_link "Featured documents", features_admin_organisation_path(organisation, locale: nil)
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

  def admin_policy_groups_header_link
    admin_header_link "Groups", admin_policy_groups_path
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
    admin_header_link "Cabinet ministers order", admin_cabinet_ministers_path
  end

  def admin_email_curation_queue_link
    admin_header_link "Email curation queue", admin_email_curation_queue_items_path
  end

  def admin_get_involved_link
    if can?(:administer, :get_involved_section)
      admin_header_link "Get involved", admin_get_involved_path
    end
  end

  def admin_sitewide_settings_link
    if can?(:administer, :sitewide_settings_section)
      admin_header_link "Sitewide settings", admin_sitewide_settings_path
    end
  end

  def admin_header_link(name, path, path_matcher = nil, options = {})
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if user_signed_in?
      li_class = active_link_class(path_matcher)
      li_class = [li_class, options[:class]].join(' ') if options[:class]
      content_tag(:li, link_to(name, path), class: li_class)
    end
  end

  def active_link_class(path_matcher)
    request.path =~ path_matcher ? 'active' : ''
  end

  def website_home_url
    main_root_url(host: public_host)
  end
end
