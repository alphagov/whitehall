class AddUnpublishedAtToUnpublishings < ActiveRecord::Migration[7.0]
  def up
    add_column :unpublishings, :unpublished_at, :datetime, null: true

    # Backfill unpublished_at with created_at values
    execute <<-SQL
      UPDATE unpublishings
      SET unpublished_at = created_at
      WHERE unpublished_at IS NULL;
    SQL

    change_column_null :unpublishings, :unpublished_at, false
  end

  def down
    remove_column :unpublishings, :unpublished_at
  end
end
