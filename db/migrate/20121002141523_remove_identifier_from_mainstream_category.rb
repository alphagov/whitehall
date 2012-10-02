class RemoveIdentifierFromMainstreamCategory < ActiveRecord::Migration
  def change
    remove_column :mainstream_categories, :identifier
  end
end
