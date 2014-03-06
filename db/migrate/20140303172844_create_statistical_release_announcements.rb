class CreateStatisticalReleaseAnnouncements < ActiveRecord::Migration
  def change
    create_table :statistical_release_announcements do |t|
      t.string      :title
      t.string      :slug
      t.text        :summary
      t.datetime    :expected_release_date
      t.string      :display_release_date_override
      t.integer     :publication_type_id
      t.references  :organisation
      t.references  :topic
      t.references  :creator

      t.timestamps
    end

    add_index :statistical_release_announcements, :creator_id
    add_index :statistical_release_announcements, :organisation_id
    add_index :statistical_release_announcements, :topic_id
    add_index :statistical_release_announcements, :slug
  end
end
