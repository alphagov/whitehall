class UpdateSubmittedDocuments < ActiveRecord::Migration
  def up
    update "UPDATE documents SET state = 'submitted' WHERE state = 'draft' AND submitted = true"
  end
  def down
    # Intentionally blank
  end
end
