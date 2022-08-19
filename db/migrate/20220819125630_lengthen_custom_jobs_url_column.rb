class LengthenCustomJobsUrlColumn < ActiveRecord::Migration[7.0]
  def up
    change_column(:organisations, :custom_jobs_url, :text)
  end

  def down
    change_column(:organisations, :custom_jobs_url, :string)
  end
end
