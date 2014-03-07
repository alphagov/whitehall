class DropUserNeeds < ActiveRecord::Migration
  def up
    drop_table :edition_user_needs
    drop_table :user_needs
  end
end
