class AddCaptionToImageOnNewsArticle < ActiveRecord::Migration
  def change
    add_column :documents, :image_caption, :text
  end
end