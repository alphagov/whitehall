module Admin::UrlHelper
  def admin_topical_events_link
    admin_link "Topical events", admin_topical_events_path
  end

  def admin_organisations_link
    admin_link "Organisations", admin_organisations_path
  end

  def admin_roles_link
    admin_link "Roles", admin_roles_path
  end

  def admin_people_link
    admin_link "People", admin_people_path
  end

  def admin_worldwide_organisations_link
    admin_link "Worldwide organisations", admin_worldwide_organisations_path unless Flipflop.editionable_worldwide_organisations?
  end

  def admin_world_location_news_link
    admin_link "World location news", admin_world_location_news_index_path
  end

  def admin_policy_groups_link
    admin_link "Groups", admin_policy_groups_path
  end

  def admin_fields_of_operation_link
    if current_user && current_user.can_handle_fatalities?
      admin_link "Fields of operation", admin_operational_fields_path
    end
  end

  def admin_cabinet_ministers_link
    admin_link "Cabinet ministers order", admin_cabinet_ministers_path
  end

  def admin_get_involved_link
    if can?(:administer, :get_involved_section)
      admin_link "Get involved", admin_get_involved_path
    end
  end

  def admin_emergency_banner_link
    if can?(:administer, :emergency_banner)
      admin_link "Emergency banner", admin_emergency_banner_path
    end
  end

  def admin_sitewide_settings_link
    if can?(:administer, :sitewide_settings_section)
      admin_link "Sitewide settings", admin_sitewide_settings_path
    end
  end

  def admin_governments_link
    admin_link "Governments", admin_governments_path
  end

  def admin_link(name, path)
    link_to(name, path, class: "govuk-link")
  end

  def admin_header_link(name, path, path_matcher = nil, options = {})
    path_matcher ||= Regexp.new("^#{Regexp.escape(path)}")
    if user_signed_in?
      li_class = active_link_class(path_matcher)
      if options[:class]
        li_class = [li_class, options[:class]].join(" ")
      end
      tag.li(link_to(name, path), class: "masthead-tab-item #{li_class}")
    end
  end

  def admin_republish_content_link
    if can?(:administer, :republish_content)
      admin_link "Republish content", admin_republishing_index_path
    end
  end

private

  def active_link_class(path_matcher)
    request.path.match?(path_matcher) ? "active" : ""
  end
end
