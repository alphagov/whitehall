class AddRevalidationPassedToEditions < ActiveRecord::Migration[8.0]
  def change
    change_table :editions, bulk: true do |t|
      t.boolean :revalidation_passed, null: false, default: true
    end
  end
end
