class DropStartEndDateFieldsFromTopicalEvents < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :topical_events, :start_date, :date
      remove_column :topical_events, :end_date, :date
    end
  end
end
