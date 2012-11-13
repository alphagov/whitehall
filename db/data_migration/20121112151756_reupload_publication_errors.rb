require 'csv'

Document.transaction do
%w(a b).each do |part|
  path = __FILE__.gsub(/\.rb/, "_#{part}.csv")
  error_path = File.basename(path).gsub(/\.csv/, '_errors.csv')
  puts "Processing #{path}"
  data = File.open(path, 'r', encoding: "UTF-8")
  PublicationUploader.new(csv_data: data, error_csv_path: error_path).upload
end
raise ActiveRecord::Rollback
end
