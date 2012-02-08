class AddUrlToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :url, :string
  end
end