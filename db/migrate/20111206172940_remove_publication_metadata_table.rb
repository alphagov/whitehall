class RemovePublicationMetadataTable < ActiveRecord::Migration
  def change
    drop_table :publication_metadata
  end
end
