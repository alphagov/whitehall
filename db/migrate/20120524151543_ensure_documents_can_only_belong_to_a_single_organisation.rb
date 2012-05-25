class EnsureDocumentsCanOnlyBelongToASingleOrganisation < ActiveRecord::Migration
  def up
    # Remove existing duplicates
    ids = select_all(%{
      SELECT id FROM document_organisations WHERE EXISTS (
        SELECT 1 FROM document_organisations duplicates
        WHERE duplicates.organisation_id = document_organisations.organisation_id
        AND duplicates.document_id = document_organisations.document_id
        AND duplicates.id < document_organisations.id)
    }).collect {|x| x["id"]}

    execute %{
      DELETE FROM document_organisations WHERE id IN (#{ids.join(", ")})
    }

    # Prevent future duplicates
    remove_index :document_organisations, :document_id
    add_index :document_organisations, [:document_id, :organisation_id], unique: true
  end

  def down
  end
end
