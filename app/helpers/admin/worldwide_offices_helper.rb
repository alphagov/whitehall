module Admin::WorldwideOfficesHelper
  def worldwide_office_tab_navigation(&block)
    tabs = {
      "Details" => admin_worldwide_office_path(@worldwide_office),
      "Contacts" => contacts_admin_worldwide_office_path(@worldwide_office),
      "People" => people_admin_worldwide_office_path(@worldwide_office),
      "Social Media Accounts" => social_media_accounts_admin_worldwide_office_path(@worldwide_office)
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