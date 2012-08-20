class AddSlugsToDocumentSeries < ActiveRecord::Migration
  def change
    add_column :document_series, :slug, :string
    add_index :document_series, :slug
  end
end
