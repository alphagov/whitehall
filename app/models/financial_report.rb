# == Schema Information
#
# Table name: financial_reports
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  funding         :integer
#  spending        :integer
#  year            :integer
#

class FinancialReport < ActiveRecord::Base
  belongs_to :organisation
  validates_associated :organisation

  validates :year, presence: true, uniqueness: {scope: :organisation_id}, numericality: {only_integer: true}
  # We allow nil because data suggests some organisations are missing some data, 0 would be inaccurate in these cases
  validates :spending, numericality: {only_integer: true}, allow_nil: true
  validates :funding, numericality: {only_integer: true}, allow_nil: true
  
end
