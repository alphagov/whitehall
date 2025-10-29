class RemoveStubFromEditions < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      remove_column :editions, :stub, :boolean
    end
  end

  def down
    add_column :editions, :stub, :boolean, default: false
  end
end
