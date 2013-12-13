class AddOrganisationChartToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :organisation_chart_url, :string
  end
end
