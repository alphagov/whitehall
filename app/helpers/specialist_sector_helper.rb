module SpecialistSectorHelper

  def add_sector_name(title, grandparent_topic)
    if grandparent_topic
      "#{link_to(grandparent_topic.title, grandparent_topic.web_url)} &ndash; #{title.downcase}".html_safe
    else
      title
    end
  end
end
