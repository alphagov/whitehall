class SpecialistTagFinder

  def initialize(document)
    @document = document
  end

  def primary_sector_tag
    primary_subsector_tag.parent if primary_subsector_tag
  end

  def primary_subsector_tag
    if primary_tag_slug = @document.primary_specialist_sector_tag
      specialist_sector_tags.find {|t| t.slug == primary_tag_slug }
    end
  end

  def sectors_and_subsectors
    specialist_sector_tags.map { |t| [t, t.parent] }.flatten.compact.uniq
  end

private

  def artefact
    @artefact ||= Whitehall.content_api.artefact(RegisterableEdition.new(@document).slug)
  end

  def specialist_sector_tags
    return [] if artefact.nil?
    artefact.tags.select {|t| t.details['type'] == 'specialist_sector' }
  end

end
