class ChangeEditionStatisticalDataSetsToPointToDocument < ActiveRecord::Migration
  def up
    # *NOTE:* This will lose existing data, but this association was only
    # added yesterday, so this is acceptable.
    add_column :edition_statistical_data_sets, :document_id, :integer
    remove_column :edition_statistical_data_sets, :statistical_data_set_id
  end

  def down
    add_column :edition_statistical_data_sets, :statistical_data_set_id, :integer
    remove_column :edition_statistical_data_sets, :document_id
  end
end
