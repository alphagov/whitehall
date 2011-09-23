module ApplicationHelper

  def navigation_link(name, path, html_options = {}, &block)
    link_to_unless_current(name, path, html_options) do
       link_to(name, path, :class => 'current')
    end
  end

  def labelled_check_box(object_name, attribute, text)
    for_attribute = [object_name, attribute].map(&:to_s).join("_")
    label_tag "", {:for => for_attribute} do
      check_box(object_name, attribute) +
      "&nbsp;".html_safe +
      content_tag(:span, text)
    end
  end

end
