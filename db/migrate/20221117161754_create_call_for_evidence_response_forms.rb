class CreateCallForEvidenceResponseForms < ActiveRecord::Migration[7.0]
  def change
    create_table :call_for_evidence_response_forms do |t|
      t.string :title
      t.integer :call_for_evidence_response_form_data_id

      t.timestamps
    end
  end
end
