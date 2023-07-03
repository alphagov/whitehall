class CreateReviewReminders < ActiveRecord::Migration[7.0]
  def up
    ## Testing a migration on integration can cause the db to get out of sync.
    ## This ensures it drops the table if present
    drop_table(:review_reminders, if_exists: true)

    create_table :review_reminders do |t|
      t.integer "document_id"
      t.integer "creator_id"
      t.string "email_address"
      t.datetime "review_at", precision: nil
      t.datetime "reminder_sent_at", precision: nil
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index %w[document_id], name: "index_review_reminders_on_document_id"
      t.index %w[creator_id], name: "index_review_reminders_on_creator_id"
    end
  end

  def down
    drop_table :review_reminders
  end
end
