# encoding: utf-8
require 'csv'

data = File.read(__FILE__.gsub(/\.rb/, '.csv'))
error_path = File.basename(__FILE__).gsub(/\.rb/, '_errors.csv')

NewsArticleUploader.new(csv_data: data, error_csv_path: error_path).upload
