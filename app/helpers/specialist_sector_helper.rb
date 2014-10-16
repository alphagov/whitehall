module SpecialistSectorHelper

  def add_sector_name(title, sector_tag)
    if sector_tag
      "#{link_to(sector_tag.title, sector_tag.web_url)} &ndash; #{title.downcase}".html_safe
    else
      title
    end
  end

  def array_of_links_to_sectors(sectors_and_subsectors)
    sectors_and_subsectors.map { |sector|
      link_to sector.title, sector.web_url, class: 'sector-link'
    }
  end

end
