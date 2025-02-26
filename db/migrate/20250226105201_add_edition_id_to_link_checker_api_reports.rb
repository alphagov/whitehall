class AddEditionIdToLinkCheckerApiReports < ActiveRecord::Migration[8.0]
  def up
    # Add the new column
    add_reference :link_checker_api_reports, :edition, foreign_key: true

    # Migrate data from polymorphic association to edition_id
    execute <<-SQL.squish
      UPDATE link_checker_api_reports
      SET edition_id = link_reportable_id
      WHERE link_reportable_type = 'Edition'
    SQL
  end

  def down
    remove_reference :link_checker_api_reports, :edition, foreign_key: true
  end
end
