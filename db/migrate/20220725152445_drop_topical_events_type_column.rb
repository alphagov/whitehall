class DropTopicalEventsTypeColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :topical_events, :type, :string, default: "TopicalEvent"
  end
end
