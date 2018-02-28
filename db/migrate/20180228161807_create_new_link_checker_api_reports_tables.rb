class CreateNewLinkCheckerApiReportsTables < ActiveRecord::Migration[5.0]
  def change
    create_table :new_link_checker_api_reports do |t|
      t.integer     :batch_id, null: false, index: { unique: true }
      t.string      :status, null: false
      t.references  :link_reportable, polymorphic: true, index: { name: 'index_link_checker_api_reportable' }
      t.timestamp   :completed_at
      t.timestamps  null: false
    end

    create_table :new_link_checker_api_report_links do |t|
      t.references  :link_checker_api_report,
                    index: { name: "index_link_checker_api_report_id" },
                    foreign_key: { to_table: :new_link_checker_api_reports }
      t.text        :uri, null: false
      t.string      :status, null: false
      t.timestamp   :checked
      t.text        :check_warnings
      t.text        :check_errors
      t.integer     :ordering, null: false
      t.text        :problem_summary
      t.text        :suggested_fix

      t.timestamps  null: false
    end

    rename_table :link_checker_api_reports, :old_link_checker_api_reports
    rename_table :new_link_checker_api_reports, :link_checker_api_reports
    reversible do |dir|
      dir.up do
        max_id = ActiveRecord::Base.connection.execute('select max(`id`) from old_link_checker_api_reports').first.first
        execute "alter table link_checker_api_reports auto_increment = #{(max_id || 0)+ 1000}"
      end
    end

    rename_table :link_checker_api_report_links, :old_link_checker_api_report_links
    rename_table :new_link_checker_api_report_links, :link_checker_api_report_links
    reversible do |dir|
      dir.up do
        max_id = ActiveRecord::Base.connection.execute('select max(`id`) from old_link_checker_api_report_links').first.first
        execute "alter table link_checker_api_report_links auto_increment = #{(max_id || 0)+ 1000}"
      end
    end
  end
end
