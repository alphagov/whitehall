class HistoricalAccountRole < ApplicationRecord
  belongs_to :role
  belongs_to :historical_account
end
