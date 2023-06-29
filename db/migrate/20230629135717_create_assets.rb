class CreateAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :assets do |t|
      t.string :asset_manager_id, null: false
      t.belongs_to :attachment_data, null: false
      t.timestamps
    end
  end
end
