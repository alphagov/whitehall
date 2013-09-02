# == Schema Information
#
# Table name: edition_statistical_data_sets
#
#  id          :integer          not null, primary key
#  edition_id  :integer
#  document_id :integer
#

class EditionStatisticalDataSet < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document
end
