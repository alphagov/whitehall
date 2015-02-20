class AddColumnGovernmentToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :government_id, :integer
  end
end
