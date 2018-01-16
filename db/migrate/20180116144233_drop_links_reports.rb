class DropLinksReports < ActiveRecord::Migration[5.0]
  def change
    drop_table :links_reports
  end
end
