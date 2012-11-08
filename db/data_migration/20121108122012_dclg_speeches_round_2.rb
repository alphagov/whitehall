require 'csv'

data = File.read(__FILE__.gsub(/\.rb/, '.csv'))

SpeechUploader.new(csv_data: data).upload
