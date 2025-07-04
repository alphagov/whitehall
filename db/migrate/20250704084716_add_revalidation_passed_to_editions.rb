class AddRevalidationPassedToEditions < ActiveRecord::Migration[8.0]
  def change
    add_column :editions, :revalidation_passed, :boolean, null: false, default: true
    add_index :editions, :revalidation_passed
  end
end
