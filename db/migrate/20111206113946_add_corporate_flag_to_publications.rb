class AddCorporateFlagToPublications < ActiveRecord::Migration
  def change
    add_column :documents, :corporate_publication, :boolean, default: false
  end
end