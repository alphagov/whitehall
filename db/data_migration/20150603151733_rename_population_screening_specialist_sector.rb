SpecialistSector.where(["edition_id IS NOT NULL AND tag LIKE ?", "nhs-population-screening-programmes%"]).each do |sector|
  sector.tag = sector.tag.sub(/\Anhs-/, "")
  sector.save!
end
