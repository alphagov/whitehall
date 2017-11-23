class CreateLinkCheckerApiReports < ActiveRecord::Migration
  def change
    create_table :link_checker_api_reports do |t|
      t.integer     :batch_id, null: false
      t.string      :status, null: false
      t.string      :link_reportable_type
      t.integer     :link_reportable_id
      t.timestamp   :completed_at

      t.timestamps  null: false

      t.index       :batch_id, unique: true
    end
  end
end
