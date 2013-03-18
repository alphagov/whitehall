class AddSlugToWorldwideOffices < ActiveRecord::Migration
  def change
    add_column :worldwide_offices, :slug, :string
    add_index :worldwide_offices, :slug
  end
end
