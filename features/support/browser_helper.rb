module BrowserHelper

  #Poltergeist can't switch to a new tab unless the tab's name is known.
  #This is a problem when following links with a target of _blank, this helper is a workaround.
  def visit_link_href(link_text)
    assert page.has_css?('a', text: link_text), "Couldn't find a link \"#{link_text}\"."
    visit(find('a', text: link_text)[:href])
  end
end

World(BrowserHelper)
