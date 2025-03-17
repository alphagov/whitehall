class MakeEditionIdUniqueOnLinkCheckerApiReports < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Remove the foreign key constraint if it exists
    if foreign_key_exists?(:link_checker_api_reports, :editions)
      remove_foreign_key :link_checker_api_reports, :editions
    end

    # Step 2: Remove the existing non-unique index if it exists
    if index_exists?(:link_checker_api_reports, :edition_id)
      remove_index :link_checker_api_reports, :edition_id
    end

    # Step 3: Add a new unique index (only if it doesn't already exist)
    unless index_exists?(:link_checker_api_reports, :edition_id, unique: true)
      add_index :link_checker_api_reports, :edition_id, unique: true
    end

    # Step 4: Re-add the foreign key constraint if it doesn't already exist
    unless foreign_key_exists?(:link_checker_api_reports, :editions)
      add_foreign_key :link_checker_api_reports, :editions, column: :edition_id
    end
  end
end
