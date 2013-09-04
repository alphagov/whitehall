# == Schema Information
#
# Table name: historical_account_roles
#
#  id                    :integer          not null, primary key
#  role_id               :integer
#  historical_account_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class HistoricalAccountRole < ActiveRecord::Base
  belongs_to :role
  belongs_to :historical_account
end
