class EditionStatisticalDataSet < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document
end
