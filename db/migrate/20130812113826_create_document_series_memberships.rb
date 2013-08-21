class CreateDocumentSeriesMemberships < ActiveRecord::Migration
  def change
    create_table :document_series_memberships do |t|
      t.belongs_to :document_series
      t.belongs_to :document
      t.integer :ordering
      t.timestamps
    end

    add_index :document_series_memberships,
              [:document_series_id, :ordering],
              name: 'index_document_series_memberships_on_series_id_and_ordering'

    add_index :document_series_memberships,
              [:document_id, :document_series_id],
              name: 'index_document_series_memberships_on_document_and_series_id'
  end
end
