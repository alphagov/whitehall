class ChangeReviewAtDatetimeToDate < ActiveRecord::Migration[7.0]
  # This migration makes two changes to the review_at column:
  #   1. Shifts values by +01:00 hour
  #   2. Changes the column from DATETIME to DATE
  #
  # Existing review_at values will be converted automatically by MySQL.
  #
  # Due to the DATETIME dates being entered by users during BST but stored as UTC,
  # the timezone shift is necessary to preserve the date as it was originally
  # entered & intended.
  #
  # For more details, use 'git blame' to see the commit message.

  def up
    ActiveRecord::Base.connection.execute("UPDATE review_reminders SET review_at = CONVERT_TZ(review_at, '+00:00', '+01:00')")
    change_column :review_reminders, :review_at, :date
  end

  def down
    change_column :review_reminders, :review_at, :datetime
    ActiveRecord::Base.connection.execute("UPDATE review_reminders SET review_at = CONVERT_TZ(review_at, '+01:00', '+00:00')")
  end
end
