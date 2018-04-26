class LinkCheckerApiReportNilBatchId < ActiveRecord::Migration[5.0]
  def change
    change_column_null :link_checker_api_reports, :batch_id, true
  end
end
