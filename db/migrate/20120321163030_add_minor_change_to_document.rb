class AddMinorChangeToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :minor_change, :boolean, default: false
  end
end
