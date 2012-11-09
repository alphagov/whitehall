require 'csv'

data = File.read(__FILE__.gsub(/\.rb/, '.csv'), mode: "r:bom|utf-8")

SpeechUploader.new(csv_data: data).upload
