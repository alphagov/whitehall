module Admin::SidebarHelper
  def simple_formatting_sidebar(options = {})
    sidebar_content = []
    sidebar_content << render("admin/editions/govspeak_help", options)
    sidebar_content << render("admin/editions/style_guidance", options)
    sidebar_content << render("admin/editions/content_block_guidance", options) if Flipflop.show_link_to_content_block_manager?
    raw sidebar_content.join("\n")
  end
end
