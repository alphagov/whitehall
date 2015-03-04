class DropPublishedRelatedPublicationCount < ActiveRecord::Migration
  def change
    remove_column :editions, :published_related_publication_count
  end
end
