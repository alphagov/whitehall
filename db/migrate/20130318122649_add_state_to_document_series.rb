class AddStateToDocumentSeries < ActiveRecord::Migration
  def change
    add_column :document_series, :state, :string, default: "current"
  end
end
