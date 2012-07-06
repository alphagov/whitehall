require_relative "../../app/models/publication_type"

class AddPublicationTypeIdToEditions < ActiveRecord::Migration
  def up
    add_column :editions, :publication_type_id, :integer
    execute "UPDATE editions SET publication_type_id = " + PublicationType::Unknown.id.to_s
    execute "UPDATE editions SET publication_type_id = " + PublicationType::CorporateReport.id.to_s + " WHERE corporate_publication=TRUE"
    execute "UPDATE editions SET publication_type_id = " + PublicationType::ResearchAndAnalysis.id.to_s + " WHERE research=TRUE"
  end

  def down
    remove_column :editions, :publication_type_id
  end
end
