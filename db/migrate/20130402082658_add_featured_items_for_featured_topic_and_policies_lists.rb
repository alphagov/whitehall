class AddFeaturedItemsForFeaturedTopicAndPoliciesLists < ActiveRecord::Migration
  def change
    create_table :featured_items do |t|
      t.references :item, polymorphic: true, null: false
      t.references :featured_topics_and_policies_list
      t.integer    :ordering
      t.datetime   :started_at
      t.datetime   :ended_at
    end
    add_index :featured_items, [:item_id, :item_type]
    # specifying name because default generated name is too long for mysql
    add_index :featured_items, [:featured_topics_and_policies_list_id, :ordering], name: 'idx_featured_items_on_featured_ts_and_ps_list_id_and_ordering'
    add_index :featured_items, :featured_topics_and_policies_list_id
  end
end
