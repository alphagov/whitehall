class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries, force: true do |t|
      t.string :name
      t.timestamps
    end
  end
end