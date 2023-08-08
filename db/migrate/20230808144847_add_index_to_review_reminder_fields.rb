class AddIndexToReviewReminderFields < ActiveRecord::Migration[7.0]
  def change
    # Create a 'multiple-column index' (a.k.a. a 'composite index')
    # https://dev.mysql.com/doc/refman/8.1/en/multiple-column-indexes.html
    #
    # This enables finding by 'review_at' alone, or by both
    # 'review_at' and 'reminder_sent_at' combined.
    # This optimises for the 'ReviewReminder.reminder_due' scope.
    add_index(:review_reminders, %i[review_at reminder_sent_at])
  end
end
