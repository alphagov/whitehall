class AddJobsUrlToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :custom_jobs_url, :string
  end
end
