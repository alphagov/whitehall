class AddLocaleToDocumentSource < ActiveRecord::Migration
  def change
    add_column :document_sources, :locale, :string, default: 'en'
  end
end
