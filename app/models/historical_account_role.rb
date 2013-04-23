class HistoricalAccountRole < ActiveRecord::Base
  belongs_to :role
  belongs_to :historical_account
end
