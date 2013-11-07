class CleanupDocumentSeriesTables < ActiveRecord::Migration
  def up
    drop_table :document_series_group_memberships
    drop_table :document_series_groups
    drop_table :document_series
  end

  def down
  end
end
