class AddDescriptionToDocumentSeries < ActiveRecord::Migration
  def change
    add_column :document_series, :description, :text
  end
end
