class AddCallForEvidenceResponseSchemas < ActiveRecord::Migration[7.0]
  def up
    create_table "call_for_evidence_response_form_data", id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.string "carrierwave_file"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end

    create_table "call_for_evidence_response_forms", id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.string "title"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.integer "call_for_evidence_response_form_data_id", foreign_key: true
    end

    create_table "call_for_evidence_participations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
      t.integer "edition_id", foreign_key: true
      t.string "link_url"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.string "email"
      t.integer "call_for_evidence_response_form_id"
      t.text "postal_address"
      t.index %w[call_for_evidence_response_form_id], name: "index_cons_participations_on_cons_response_form_id"
      t.index %w[edition_id], name: "index_call_for_evidence_participations_on_edition_id"
    end
  end

  def down
    drop_table "call_for_evidence_response_form_data"
    drop_table "call_for_evidence_response_forms"
    drop_table "call_for_evidence_participations"
  end
end
