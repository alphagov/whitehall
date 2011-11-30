class AddEditorialGuidanceToNewsArticles < ActiveRecord::Migration
  def change
    add_column :documents, :editorial_guidance, :text
  end
end