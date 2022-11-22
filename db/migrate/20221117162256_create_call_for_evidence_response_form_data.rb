class CreateCallForEvidenceResponseFormData < ActiveRecord::Migration[7.0]
  def change
    create_table :call_for_evidence_response_form_data do |t|
      t.string "carrierwave_file"

      t.timestamps
    end
  end
end
