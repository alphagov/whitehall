class AddTopicalEventToFeature < ActiveRecord::Migration
  def change
    add_column :features, :topical_event_id, :integer
  end
end
