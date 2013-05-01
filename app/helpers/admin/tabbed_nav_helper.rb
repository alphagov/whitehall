module Admin::TabbedNavHelper
  def tab_navigation_for(content_object, *extra_classes, &block)
    case content_object
    when Organisation
      tab_navigation(organisation_tabs(content_object), *extra_classes, &block)
    when WorldwideOrganisation
      tab_navigation(worldwide_organisation_tabs(content_object), *extra_classes, &block)
    when WorldLocation
      tab_navigation(world_location_tabs(content_object), *extra_classes, &block)
    when Person
      tab_navigation(person_tabs(content_object), *extra_classes, &block)
    end
  end

  def person_tabs(person)
    { 'Details' => admin_person_path(person),
      'Translations' => admin_person_translations_path(person),
      'Historical accounts' => admin_person_historical_accounts_path(person) }
  end

  def tab_navigation(tabs, *extra_classes, &block)
    tabs = tab_navigation_header(tabs)
    content_tag(:div, class: ['tabbable', *extra_classes] ) do
      if block_given?
        tabs + content_tag(:div, class: "tab-content") { yield }
      else
        tabs
      end
    end
  end

  def tab_navigation_header(tabs)
    content_tag(:ul, class: %w(nav nav-tabs)) do
      tabs.map { |label, url|
        content_tag(:li, link_to(label, url), class: class_for_tab(url))
      }.join.html_safe
    end
  end

  def class_for_tab(url)
    request.path == url ? :active : nil
  end
end
