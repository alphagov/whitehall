class CreateCallForEvidenceResponseTable < ActiveRecord::Migration[7.0]
  def change
    create_table :call_for_evidence_responses do |t|
      t.integer "edition_id"
      t.text "summary"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.date "published_on"
      t.string "type"
      t.index %w[edition_id type], name: "index_call_for_evidence_responses_on_edition_id_and_type"
      t.index %w[edition_id], name: "index_call_for_evidence_responses_on_edition_id"
    end
  end
end
