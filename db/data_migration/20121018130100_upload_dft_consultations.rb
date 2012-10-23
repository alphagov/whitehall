require 'csv'

data = File.open(__FILE__.gsub(/\.rb/, '.csv'), 'r', encoding: "UTF-8")

ConsultationUploader.new(csv_data: data).upload
