class EditionStatisticalDataSet < ActiveRecord::Base
  belongs_to :edition
  belongs_to :statistical_data_set
end
