class AssociateTopicsWithEditionNotPolicy < ActiveRecord::Migration
  def up
    remove_index :topic_memberships, name: :index_policy_topic_memberships_on_policy_id
    remove_index :topic_memberships, name: :index_policy_topic_memberships_on_policy_topic_id
    rename_column :topic_memberships, :policy_id, :edition_id
    add_index :topic_memberships, :edition_id, name: :index_topic_memberships_on_edition_id
    add_index :topic_memberships, :topic_id, name: :index_topic_memberships_on_topic_id
  end

  def down
    remove_index :topic_memberships, name: :index_topic_memberships_on_topic_id
    remove_index :topic_memberships, name: :index_topic_memberships_on_edition_id
    rename_column :topic_memberships, :edition_id, :policy_id
    add_index :topic_memberships, :topic_id, name: :index_policy_topic_memberships_on_policy_topic_id
    add_index :topic_memberships, :policy_id, name: :index_policy_topic_memberships_on_policy_id
  end
end
