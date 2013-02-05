class AddLocalGovernmentRelevanceToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :relevant_to_local_government, :boolean, default: false
  end
end
