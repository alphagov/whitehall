class AddWorldwideOfficeWorldwideServices < ActiveRecord::Migration
  def change
    create_table :worldwide_office_worldwide_services, force: true do |t|
      t.references :worldwide_office, null: false
      t.references :worldwide_service, null: false
      t.timestamps
    end
  end
end
