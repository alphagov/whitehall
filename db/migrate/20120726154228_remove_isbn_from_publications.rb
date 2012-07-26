class RemoveIsbnFromPublications < ActiveRecord::Migration
  def up
    remove_column :editions, :isbn
  end

  def down
    add_column :editions, :isbn, :string
  end
end
