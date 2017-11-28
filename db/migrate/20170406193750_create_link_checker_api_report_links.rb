class CreateLinkCheckerApiReportLinks < ActiveRecord::Migration
  def change
    create_table :link_checker_api_report_links do |t|
      t.references  :link_checker_api_report,
                    index: { name: "index_link_checker_api_report_id" },
                    foreign_key: true
      t.string      :uri, null: false
      t.string      :status, null: false
      t.timestamp   :checked
      t.text        :check_warnings
      t.text        :check_errors
      t.integer     :ordering, null: false

      t.timestamps  null: false
    end
  end
end
