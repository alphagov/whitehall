# encoding: utf-8
require 'csv'

data = File.open(__FILE__.gsub(/\.rb/, '.csv'), "r:bom|utf-8")
error_path = File.basename(__FILE__).gsub(/\.rb/, '_errors.csv')

StatisticalDataSetUploader.new(csv_data: data, error_csv_path: error_path).upload
