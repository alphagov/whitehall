module AdminBrokenLinksReportingHelper
  def govspeak_with_links(*links)
    "Some content with links: ##{build_links(links).join(' ')}"
  end

  def build_links(links)
    links.each_with_index.map { |link, i| "[Link #{i}](#{link})" }
  end
end

World(AdminBrokenLinksReportingHelper)
