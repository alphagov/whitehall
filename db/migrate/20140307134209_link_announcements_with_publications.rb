class LinkAnnouncementsWithPublications < ActiveRecord::Migration
  def change
    add_column :statistics_announcements, :publication_id, :integer
    add_index  :statistics_announcements, :publication_id
  end
end
