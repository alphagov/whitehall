module Admin::TabbedNavHelper
  def tab_navigation_for(organisation, &block)
    case organisation
    when Organisation
      organisation_tab_navigation(organisation, &block)
    when WorldwideOrganisation
      worldwide_organisation_tab_navigation(organisation, &block)
    end
  end

  def tab_navigation(tabs, &block)
    content_tag(:div, class: :tabbable) do
      tab_navigation_header(tabs) + content_tag(:div, class: "tab-content") { yield }
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
