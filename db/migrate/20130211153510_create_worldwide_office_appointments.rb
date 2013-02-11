class CreateWorldwideOfficeAppointments < ActiveRecord::Migration
  def change
    create_table :worldwide_office_appointments do |t|
      t.references :worldwide_office
      t.references :person
      t.string     :job_title

      t.timestamps
    end

    add_index :worldwide_office_appointments, :worldwide_office_id
    add_index :worldwide_office_appointments, :person_id
  end
end
