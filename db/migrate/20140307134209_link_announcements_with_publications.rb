class LinkAnnouncementsWithPublications < ActiveRecord::Migration
  def change
    add_column :statistical_release_announcements, :publication_id, :integer
    add_index  :statistical_release_announcements, :publication_id
  end
end
