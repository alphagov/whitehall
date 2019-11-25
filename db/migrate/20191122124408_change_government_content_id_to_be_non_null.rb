class ChangeGovernmentContentIdToBeNonNull < ActiveRecord::Migration[5.1]
  def change
    change_column :governments, :content_id, :string, null: false
    add_index :governments, :content_id, unique: true
  end
end
