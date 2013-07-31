class AddIndexToFinancialReports < ActiveRecord::Migration
  def change
    add_index :financial_reports, ["organisation_id", "year"], unique: true
  end
end
