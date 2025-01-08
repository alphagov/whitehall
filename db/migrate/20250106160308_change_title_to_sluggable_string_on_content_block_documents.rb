class ChangeTitleToSluggableStringOnContentBlockDocuments < ActiveRecord::Migration[7.1]
  def up
    rename_column :content_block_documents, :title, :sluggable_string
  end

  def down
    rename_column :content_block_documents, :sluggable_string, :title
  end
end
