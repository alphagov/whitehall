class AddImportIdAndRowNumberToDocumentSources < ActiveRecord::Migration
  def change
    add_column :document_sources, :import_id, :integer
    add_column :document_sources, :row_number, :integer
  end
end
