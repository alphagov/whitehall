class CreateFinancialReport < ActiveRecord::Migration
  def change
    create_table :financial_reports do |t|
      t.belongs_to :organisation
      t.integer :funding, limit: 8#Default is insufficient for large spends
      t.integer :spending, limit: 8
      t.integer :year
    end
    add_index :financial_reports, :organisation_id
    add_index :financial_reports, :year
  end
end
