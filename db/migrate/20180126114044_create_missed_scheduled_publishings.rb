class CreateMissedScheduledPublishings < ActiveRecord::Migration[5.0]
  def change
    create_table :missed_scheduled_publishings do |t|
      t.string :url
      t.string :announcement_url
      t.datetime :scheduled_publication
      t.string :status
      t.boolean :found_at_first_attempt

      t.timestamps
    end
  end
end
