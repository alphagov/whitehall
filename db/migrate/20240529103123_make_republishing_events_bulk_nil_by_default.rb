class MakeRepublishingEventsBulkNilByDefault < ActiveRecord::Migration[7.1]
  change_column_default(:republishing_events, :bulk, nil)
end
