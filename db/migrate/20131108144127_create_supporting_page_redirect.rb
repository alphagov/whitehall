class CreateSupportingPageRedirect < ActiveRecord::Migration
  def change
    create_table :supporting_page_redirects do |t|
      t.integer :policy_document_id
      t.integer :supporting_page_document_id
      t.string :original_slug

      t.timestamps
    end

    add_index :supporting_page_redirects, [:policy_document_id, :original_slug], unique: true, name: "index_supporting_page_redirects_on_policy_and_slug"
  end
end
