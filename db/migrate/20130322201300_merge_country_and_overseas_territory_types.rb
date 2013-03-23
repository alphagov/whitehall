class MergeCountryAndOverseasTerritoryTypes < ActiveRecord::Migration
  class WorldLocation < ActiveRecord::Base; end
  def up
    execute %{
        UPDATE #{WorldLocation.arel_table.name}
        SET world_location_type_id = 1
        WHERE world_location_type_id = 2
    }
  end

  def down
    # No down, this is destructive.
  end
end
