class RemoveOldSupportingPagesTable < ActiveRecord::Migration
  def up
    drop_table :supporting_pages
  end
end
