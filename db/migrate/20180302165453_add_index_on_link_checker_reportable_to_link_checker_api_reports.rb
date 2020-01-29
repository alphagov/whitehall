class AddIndexOnLinkCheckerReportableToLinkCheckerApiReports < ActiveRecord::Migration[5.0]
  def change
    add_index :link_checker_api_reports, %i[link_reportable_type link_reportable_id], name: "index_link_checker_api_reportable"
  end
end
