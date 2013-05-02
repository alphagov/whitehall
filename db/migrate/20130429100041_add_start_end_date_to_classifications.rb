class AddStartEndDateToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :start_date, :date
    add_column :classifications, :end_date, :date
  end
end
