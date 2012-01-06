class AddFeaturedToDocumentOrganisationsRelation < ActiveRecord::Migration
  def change
    add_column :document_organisations, :featured, :boolean, default: false
  end
end