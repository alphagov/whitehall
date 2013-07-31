class AddTypeToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :type, :string
    add_index  :responses, [:edition_id, :type]
  end
end
