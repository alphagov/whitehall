class CacheNumberOfPublishedEditionsOnTopic < ActiveRecord::Migration
  class Topic < ActiveRecord::Base
    has_many :topic_memberships
    has_many :published_editions, through: :topic_memberships, conditions: { state: "published" }, source: :edition
    def update_counts
      update_column(:published_edition_count, published_editions.count)
    end
  end

  class Edition < ActiveRecord::Base
    has_many :topic_memberships, foreign_key: :edition_id
  end

  class TopicMembership < ActiveRecord::Base
    belongs_to :edition
    belongs_to :topic
  end

  def up
    add_column "topics", "published_edition_count", :integer, null: false, default: 0
    Topic.all.each(&:update_counts)
  end

  def down
    remove_column "topics", "published_edition_count"
  end
end
