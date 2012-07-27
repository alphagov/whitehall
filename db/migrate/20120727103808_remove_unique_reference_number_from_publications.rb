class RemoveUniqueReferenceNumberFromPublications < ActiveRecord::Migration
  def up
    remove_column :editions, :unique_reference
  end

  def down
    add_column :editions, :unique_reference, :string
  end
end
