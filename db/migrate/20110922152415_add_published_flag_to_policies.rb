class AddPublishedFlagToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :published, :boolean, :default => false
  end
end