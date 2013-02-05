class AddIso2ToWorldLocations < ActiveRecord::Migration
  class WorldLocation < ActiveRecord::Base
  end

  def up
    add_column :world_locations, :iso2, :string, limit: 2
    add_index :world_locations, :iso2, unique: true

    # Data in Google doc
    # https://docs.google.com/a/digital.cabinet-office.gov.uk/spreadsheet/ccc?key=0Au2ZT9FFPER-dG42ZXJfdk1qeEhvTUYxY3pwN0hCWWc
    require 'csv'
    CSV.foreach(File.dirname(__FILE__) + "/20130117162714_add_iso2_to_world_locations.csv", headers: true, encoding: 'utf-8') do |row|
      next unless row['ISO2 Code']
      w = WorldLocation.find(row['Database ID']) rescue next
      w.iso2 = row['ISO2 Code']
      w.save!
    end
  end

  def down
    remove_index :world_locations, :iso2
    remove_column :world_locations, :iso2
  end
end
