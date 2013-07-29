class AddClosedStateToOrgs < ActiveRecord::Migration
  def change
    add_column :organisations, :closed_at, :datetime
  end
end
