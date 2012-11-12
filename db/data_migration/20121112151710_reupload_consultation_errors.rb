require 'csv'

data = File.open(__FILE__.gsub(/\.rb/, '.csv'), 'r', encoding: "UTF-8")
error_path = File.basename(__FILE__).gsub(/\.rb/, '_errors.csv')

ConsultationUploader.new(csv_data: data, error_csv_path: error_path).upload
