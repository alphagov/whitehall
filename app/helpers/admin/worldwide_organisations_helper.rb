module Admin::WorldwideOrganisationsHelper
  def worldwide_organisation_tab_navigation(&block)
    tabs = {
      "Details" => admin_worldwide_organisation_path(@worldwide_organisation),
      "Offices" => offices_admin_worldwide_organisation_path(@worldwide_organisation),
      "Social Media Accounts" => social_media_accounts_admin_worldwide_organisation_path(@worldwide_organisation)
    }

    tab_navigation(tabs, &block)
  end

  def tab_navigation(tabs, &block)
    content_tag(:div, class: :tabbable) do
      content_tag(:ul, class: %w{nav nav-tabs}) do
        tabs.map do |label, url|
          content_tag(:li, class: request.path == url ? :active : nil) do
            link_to(label, url)
          end
        end.join.html_safe
      end +
        content_tag(:div, class: "tab-content") do
          yield
        end
    end
  end
end