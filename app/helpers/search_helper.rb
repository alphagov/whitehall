module SearchHelper
  def search_highlight(text_from_solr)
    text = text_from_solr.gsub(/HIGHLIGHT_START/, "<strong>").gsub(/HIGHLIGHT_END/, "</strong>")
    "&hellip;#{text}&hellip;".html_safe
  end

  def citizen_search_link(link_text, query, html_options = {})
    link_to link_text, "/search?q=#{CGI.escape(query)}", html_options
  end
end