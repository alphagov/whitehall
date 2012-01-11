class PopulateMissingDocumentIdentityTypes < ActiveRecord::Migration
  def up
    document_ids_and_types = select_all("SELECT document_identity_id AS id, type FROM documents GROUP BY document_identity_id, type")
    document_ids_and_types.each do |row|
      id, type = row["id"], row["type"]
      update "UPDATE document_identities SET document_type = '#{type}' WHERE id = #{id} AND document_type IS NULL"
    end
  end

  def down
    # Intentionally blank
  end
end
