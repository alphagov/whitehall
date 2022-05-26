class AddSummaryToClassifications < ActiveRecord::Migration[7.0]
  def change
    add_column :classifications, :summary, :text
  end
end
