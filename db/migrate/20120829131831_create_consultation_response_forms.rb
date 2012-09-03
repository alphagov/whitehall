class CreateConsultationResponseForms < ActiveRecord::Migration
  def change
    create_table :consultation_response_forms do |t|
      t.string :carrierwave_file
      t.string :title

      t.timestamps
    end

    add_column :consultation_participations, :consultation_response_form_id, :integer
  end
end
