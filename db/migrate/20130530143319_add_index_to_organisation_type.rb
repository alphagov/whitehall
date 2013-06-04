class AddIndexToOrganisationType < ActiveRecord::Migration
  def change
    add_index :organisation_types, :name
  end
end
