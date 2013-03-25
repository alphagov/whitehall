module Admin::TabbedNavHelper
  def tab_navigation_for(organisation, &block)
    case organisation
    when Organisation
      tab_navigation(organisation_tabs(organisation), &block)
    when WorldwideOrganisation
      tab_navigation(worldwide_organisation_tabs(organisation), &block)
    when WorldLocation
      tab_navigation(world_location_tabs(organisation), &block)
    end
  end

  def tab_navigation(tabs, &block)
    tab_navigation_header(tabs).tap do |tabs|
      if block_given?
        content_tag(:div, class: :tabbable) do
          tabs + content_tag(:div, class: "tab-content") { yield }
        end
      end
    end
  end

  def tab_navigation_header(tabs)
    content_tag(:ul, class: %w{nav nav-tabs}) do
      tabs.map do |label, url|
        content_tag(:li, link_to(label, url), class: class_for_tab(url))
      end.join.html_safe
    end
  end

  def class_for_tab(url)
    request.path == url ? :active : nil
  end
end
