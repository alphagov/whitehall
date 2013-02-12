class AddTranslationsForWorldLocations < ActiveRecord::Migration
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
