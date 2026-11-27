class DropTopicalEventIdFromFeatures < ActiveRecord::Migration[8.1]
  def change
    # Feature already ignores this column, so it's safe to drop.
    safety_assured do
      remove_column :features, :topical_event_id, :integer
    end
  end
end
