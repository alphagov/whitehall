class AddSummaryToDocumentSeries < ActiveRecord::Migration
  def change
    add_column :document_series, :summary, :string
  end
end
