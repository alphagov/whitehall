class CreateFeatures < ActiveRecord::Migration[7.0]
  def change
    create_table :flipflop_features do |t|
      t.string :key, null: false
      t.boolean :enabled, null: false, default: false

      t.timestamps null: false
    end
  end
end
