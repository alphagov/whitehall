class AddStateAndTypeIndexesToEditionsTable < ActiveRecord::Migration
  def change
    add_index :editions, :type
    add_index :editions, :state
  end
end
