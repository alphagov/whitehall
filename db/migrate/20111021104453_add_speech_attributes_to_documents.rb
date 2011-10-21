class AddSpeechAttributesToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :role_appointment_id, :integer
    add_column :documents, :location, :string
    add_column :documents, :delivered_on, :date
  end
end
