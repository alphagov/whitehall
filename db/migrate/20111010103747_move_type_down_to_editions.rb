class MoveTypeDownToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :type, :string
    remove_column :documents, :type
  end
end
