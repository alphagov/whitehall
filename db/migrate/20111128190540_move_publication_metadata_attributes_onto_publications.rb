class MovePublicationMetadataAttributesOntoPublications < ActiveRecord::Migration
  def change
    add_column :documents, :publication_date, :date
    add_column :documents, :unique_reference, :string
    add_column :documents, :isbn, :string
    add_column :documents, :research, :boolean, default: false
    add_column :documents, :order_url, :string

    update %{
      UPDATE documents, publication_metadata
        SET documents.publication_date = publication_metadata.publication_date,
            documents.unique_reference = publication_metadata.unique_reference,
            documents.isbn = publication_metadata.isbn,
            documents.research = publication_metadata.research,
            documents.order_url = publication_metadata.order_url,
            documents.updated_at = GREATEST(documents.updated_at, publication_metadata.updated_at)
        WHERE documents.id = publication_metadata.publication_id
        AND documents.type = 'Publication'
    }
  end
end
