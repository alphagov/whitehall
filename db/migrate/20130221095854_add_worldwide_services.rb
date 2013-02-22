class AddWorldwideServices < ActiveRecord::Migration
  def change
    create_table :worldwide_services, force: true do |t|
      t.string :name, null: false
      t.integer :service_type_id, null: false
      t.timestamps
    end
  end
end
