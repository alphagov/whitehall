class AddGovernmentsForeignKeyToEditions < ActiveRecord::Migration[7.1]
  def change
    change_table :editions do |t|
      t.integer :government_id
    end
    add_foreign_key :editions, :governments, on_delete: :nullify
  end
end
