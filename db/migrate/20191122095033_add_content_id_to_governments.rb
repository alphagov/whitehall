class AddContentIdToGovernments < ActiveRecord::Migration[5.1]
  def change
    add_column :governments, :content_id, :string
  end
end
