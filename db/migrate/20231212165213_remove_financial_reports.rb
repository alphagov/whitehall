class RemoveFinancialReports < ActiveRecord::Migration[7.0]
  def up
    drop_table :financial_reports
  end

  def down
    create_table :financial_reports do |t|
      t.integer "organisation_id"
      t.bigint "funding"
      t.bigint "spending"
      t.integer "year"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index %w[organisation_id year], name: "index_financial_reports_on_organisation_id_and_year", unique: true
      t.index %w[organisation_id], name: "index_financial_reports_on_organisation_id"
      t.index %w[year], name: "index_financial_reports_on_year"
    end
  end
end
