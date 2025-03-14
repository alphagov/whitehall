# rubocop:disable Rails/BulkChangeTable
class MakeEditionIdUniqueOnLinkCheckerApiReports < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Remove the foreign key constraint
    remove_foreign_key :link_checker_api_reports, :editions

    # Step 2: Remove the existing non-unique index
    remove_index :link_checker_api_reports, :edition_id

    # Step 3: Add a new unique index
    add_index :link_checker_api_reports, :edition_id, unique: true

    # Step 4: Re-add the foreign key constraint if required
    add_foreign_key :link_checker_api_reports, :editions, column: :edition_id
  end
end
# rubocop:enable Rails/BulkChangeTable
