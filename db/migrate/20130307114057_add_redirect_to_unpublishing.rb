class AddRedirectToUnpublishing < ActiveRecord::Migration
  def change
    add_column :unpublishings, :redirect, :boolean, default: false
  end
end
