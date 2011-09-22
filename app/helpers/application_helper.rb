module ApplicationHelper

  def navigation_link(name, path, html_options = {}, &block)
    link_to_unless_current(name, path, html_options) do
       link_to(name, path, :class => 'current')
    end
  end

end
