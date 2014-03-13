module SpecialistSectorHelper

  def add_sector_name(title)
    if primary_subsector_tag && sector_tag = primary_subsector_tag.parent
      "#{link_to(sector_tag.title, sector_tag.web_url)} - #{title.downcase}".html_safe
    else
      title
    end
  end

  def add_subsector_name(title)
    if primary_subsector_tag
      "#{primary_subsector_tag.title} - #{title}"
    else
      title
    end
  end

  def array_of_links_to_sectors(subsectors)
    sectors_and_subsectors = specialist_sector_tags.map { |s| [s, s.parent] }

    sectors_and_subsectors.flatten.compact.uniq.map { |sector|
      link_to sector.title, sector.web_url
    }
  end

private

  def artefact
    @artefact ||= Whitehall.content_api.artefact(RegisterableEdition.new(@document).slug)
  end

  def specialist_sector_tags
    return [] if artefact.nil?
    @specialist_sector_tags ||= artefact.tags.select {|t| t.details['type'] == 'specialist_sector' }
  end

  def primary_subsector_tag
    @primary_subsector_tag ||= if primary_tag_slug = @document.primary_specialist_sector_tag
      specialist_sector_tags.find {|t| t.slug == primary_tag_slug }
    end
  end

end
