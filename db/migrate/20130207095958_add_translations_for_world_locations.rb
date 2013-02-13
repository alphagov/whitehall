class AddTranslationsForWorldLocations < ActiveRecord::Migration
  class WorldLocation < ActiveRecord::Base
    translates :name, :mission_statement
  end

  def up
    WorldLocation.create_translation_table!({
      name: :string, mission_statement: :text
    }, {
      migrate_data: true
    })
    remove_column :world_locations, :name
    remove_column :world_locations, :mission_statement
  end

  def down
    WorldLocation.drop_translation_table!(migrate_data: true)
  end
end
