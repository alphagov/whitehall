class CacheNumberOfPublishedPoliciesOnTopic < ActiveRecord::Migration
  def up
    add_column "topics", "published_policies_count", :integer, null: false, default: 0
    execute %{
      update topics set published_policies_count = (
        select count(*) from editions
        join topic_memberships ON (topic_memberships.edition_id = editions.id)
        where topic_memberships.topic_id = topics.id
        and editions.type = 'Policy'
        and editions.state = 'published'
      )
    }
  end

  def down
    remove_column "topics", "published_policies_count"
  end
end
