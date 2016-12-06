# This DfT publication 'ict-spend' has one statistical data set
# which is superseded and has the slug 'average-house-prices'
# so assume this is a bad relationship and disconnect the two.
pub = Publication.find(392444)
pub.statistical_data_sets = (pub.statistical_data_sets - [data_set])
pub.save!
