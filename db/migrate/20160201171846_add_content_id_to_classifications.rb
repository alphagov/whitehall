class AddContentIdToClassifications < ActiveRecord::Migration
  def change
    add_column :classifications, :content_id, :string
  end
end
