class CreateWorldwideOffices < ActiveRecord::Migration
  def change
    create_table :worldwide_offices do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.string :url
      t.string :slug
      t.string :logo_formatted_name

      t.timestamps
    end

    add_index :worldwide_offices, :slug, unique: true
  end
end
