class ChangeUriColumnOnLinkCheckerReportLinks < ActiveRecord::Migration[5.0]
  def up
    change_column :link_checker_api_report_links, :uri, :text, null: false
  end

  def down
    change_column :link_checker_api_report_links, :uri, :string, null: false
  end
end
