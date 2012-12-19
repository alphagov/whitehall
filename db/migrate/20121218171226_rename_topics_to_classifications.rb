class RenameTopicsToClassifications < ActiveRecord::Migration
  def up
    rename_table :topics, :classifications
    add_column :classifications, :type, :string
    execute "update classifications set type='Topic'"
  end

  def down
    remove_column :classifications, :type
    rename_table :classifications, :topics
  end
end
