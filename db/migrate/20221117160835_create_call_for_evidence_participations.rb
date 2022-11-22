class CreateCallForEvidenceParticipations < ActiveRecord::Migration[7.0]
  def change
    create_table :call_for_evidence_participations do |t|
      t.integer :edition_id, foreign_key: true
      t.string :link_url
      t.string :email
      t.integer :call_for_evidence_response_form_id
      t.text :postal_address
      t.timestamps

      t.index :call_for_evidence_response_form_id, name: :index_cfe_participations_on_cfe_response_form_id
      t.index :edition_id, name: :index_call_for_evidence_participations_on_edition_id
    end
  end
end
