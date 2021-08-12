class AddNewCustomJobsUrlToGeospatialCommissionOrg < ActiveRecord::Migration[6.0]
  def change
    change_column :organisations, :custom_jobs_url, :text
  end
end
