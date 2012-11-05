class CreateEditionStatisticalDataSets < ActiveRecord::Migration
  def change
    create_table :edition_statistical_data_sets, force: true do |t|
      t.references :edition
      t.references :statistical_data_set
    end
  end
end
