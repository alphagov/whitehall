class RelateDocumentsToPolicyIdentity < ActiveRecord::Migration
  def change
    rename_table "document_relations", "old_document_relations"

    create_table "document_relations", force: true do |t|
      t.integer  "document_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "document_identity_id"
    end

    update %{
      insert into document_relations (document_id, document_identity_id)
      select distinct document_id, document_identity_id
      from old_document_relations
      join documents on (old_document_relations.policy_id = documents.id)
    }

    drop_table "old_document_relations"
  end
end
