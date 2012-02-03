class AddImageDescriptionToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :image_alt_text, :string
  end
end
