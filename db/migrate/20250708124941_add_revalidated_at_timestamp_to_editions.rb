class AddRevalidatedAtTimestampToEditions < ActiveRecord::Migration[8.0]
  def change
    change_table :editions, bulk: true do |t|
      t.datetime :revalidated_at
    end
  end
end
