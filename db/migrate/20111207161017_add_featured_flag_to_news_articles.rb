class AddFeaturedFlagToNewsArticles < ActiveRecord::Migration
  def change
    add_column :documents, :featured, :boolean, default: false
  end
end