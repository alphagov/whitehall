class AddContentIdToAboutPage < ActiveRecord::Migration
  def change
    add_column :about_pages, :content_id, :string
  end
end
