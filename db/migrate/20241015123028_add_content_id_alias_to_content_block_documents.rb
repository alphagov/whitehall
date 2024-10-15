class AddContentIdAliasToContentBlockDocuments < ActiveRecord::Migration[7.1]
  def change
    change_table :content_block_documents, bulk: true do |t|
      t.column :content_id_alias, :string
      t.index :content_id_alias, unique: true
    end
  end
end
