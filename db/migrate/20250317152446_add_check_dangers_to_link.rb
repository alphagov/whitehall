class AddCheckDangersToLink < ActiveRecord::Migration[8.0]
  def change
    add_column :link_checker_api_report_links, :check_dangers, :text, limit: 16.megabytes - 1
  end
end
