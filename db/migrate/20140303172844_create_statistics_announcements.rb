class CreateStatisticsAnnouncements < ActiveRecord::Migration
  def change
    create_table :statistics_announcements do |t|
      t.string      :title
      t.string      :slug
      t.text        :summary
      t.integer     :publication_type_id
      t.references  :organisation
      t.references  :topic
      t.references  :creator

      t.timestamps
    end

    add_index :statistics_announcements, :slug
    add_index :statistics_announcements, :title
    add_index :statistics_announcements, :creator_id
    add_index :statistics_announcements, :organisation_id
    add_index :statistics_announcements, :topic_id
  end
end
