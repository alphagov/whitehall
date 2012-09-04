class RemoveTopicFeaturing < ActiveRecord::Migration
  def up
    remove_column :topics, :featured
  end

  def down
    add_column :topics, :featured, :boolean, default: false
  end
end
