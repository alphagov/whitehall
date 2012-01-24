class AddBiographyToPeople < ActiveRecord::Migration
  def change
    add_column :people, :biography, :text
  end
end