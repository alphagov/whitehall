class Api::LicenceSectorsPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      id: model.id,
      parent_sector_id: model.parent_sector_id,
      title: model.title,
      sectors: sectors(model.sectors),
    }
  end

private

  def sectors(sectors)
    sectors.map do |sector|
      {
        id: sector.id,
        parent_sector_id: sector.parent_sector_id,
        title: sector.title,
        sectors: sectors(sector.sectors),
      }
    end
  end
end
