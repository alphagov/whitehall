module Admin::SidebarHelper
  def simple_formatting_sidebar(options = {})
    sidebar_content = []
    sidebar_content << render("admin/editions/govspeak_help", options)
    sidebar_content << render("admin/editions/landing_page_help", options) if options[:show_landing_page_help]
    sidebar_content << render("admin/editions/style_guidance", options)
    raw sidebar_content.join("\n")
  end
end
