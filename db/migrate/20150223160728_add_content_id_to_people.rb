class AddContentIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :content_id, :string
  end
end
