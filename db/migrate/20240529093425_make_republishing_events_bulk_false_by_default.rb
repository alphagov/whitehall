class MakeRepublishingEventsBulkFalseByDefault < ActiveRecord::Migration[7.1]
  def up
    change_column :republishing_events, :bulk, :boolean, default: false
  end

  def down; end
end
