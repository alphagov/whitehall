class DropDocumentSeriesMemberships < ActiveRecord::Migration
  def up
    drop_table :document_series_memberships
  end
end
