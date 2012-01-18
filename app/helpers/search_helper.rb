module SearchHelper
  def search_highlight(text_from_solr)
    text = text_from_solr.gsub(/HIGHLIGHT_START/, "<strong>").gsub(/HIGHLIGHT_END/, "</strong>")
    "&hellip;#{text}&hellip;".html_safe
  end
end