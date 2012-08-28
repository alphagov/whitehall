class RemoveFeaturedFlagFromTopicMemberships < ActiveRecord::Migration
  def change
    remove_column :topic_memberships, :featured
  end
end
