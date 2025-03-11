# rubocop:disable Rails/BulkChangeTable
class RemoveLinkReportableFieldsFromLinkCheckerApiReports < ActiveRecord::Migration[8.0]
  def up
    remove_index :link_checker_api_reports, name: "index_link_checker_api_reportable"
    remove_column :link_checker_api_reports, :link_reportable_type
    remove_column :link_checker_api_reports, :link_reportable_id
  end

  def down
    add_column :link_checker_api_reports, :link_reportable_type, :string
    add_column :link_checker_api_reports, :link_reportable_id, :integer
    add_index :link_checker_api_reports, %i[link_reportable_type link_reportable_id], name: "index_link_checker_api_reportable"

    # Restore data
    execute <<-SQL.squish
      UPDATE link_checker_api_reports
      SET link_reportable_type = 'Edition', link_reportable_id = edition_id
      WHERE edition_id IS NOT NULL
    SQL
  end
end
# rubocop:enable Rails/BulkChangeTable
