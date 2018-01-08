module SpecialistSectorHelper
  def add_sector_name(title, top_level_topic)
    if top_level_topic
      "#{link_to(top_level_topic['title'], top_level_topic['web_url'])} &ndash; #{title.downcase}".html_safe
    else
      title
    end
  end
end
