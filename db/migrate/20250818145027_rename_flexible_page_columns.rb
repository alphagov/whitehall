# We are forcing the column rename, as there is no edition data with the old column name.
class RenameFlexiblePageColumns < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      rename_column :editions, :flexible_page_type, :configurable_document_type
      rename_column :edition_translations, :flexible_page_content, :block_content
    end
  end
end
