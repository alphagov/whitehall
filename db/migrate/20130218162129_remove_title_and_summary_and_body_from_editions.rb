class RemoveTitleAndSummaryAndBodyFromEditions < ActiveRecord::Migration
  def up
    # No-op.
    # This migration previously removed the title, summary and body fields from the editions table
    # but that caused us problems with stale Rails processes expecting the fields to exist after
    # deployment.
  end

  def self.down
    # No-op. See the comment above.
  end
end
