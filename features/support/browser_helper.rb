module BrowserHelper

  # We've had trouble getting poltergeist/phantomjs to follow links to new windows (e.g. target="_blank").
  # This helper bybasses things by visiting the URL instead of clicking the link.
  def visit_link_href(link_text)
    assert page.has_css?('a', text: link_text, count: 1)
    visit(find(:link, link_text)[:href])
  end
end

World(BrowserHelper)
