class AddAcronymToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :acronym, :string
  end
end