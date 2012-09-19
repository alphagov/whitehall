class UnfeatureAllDocumentsFeaturedWithinOrganisations < ActiveRecord::Migration
  def up
    update %{
      UPDATE edition_organisations SET featured = false, updated_at = NOW()
    }
  end

  def down
    # Irreversible migration
  end
end
