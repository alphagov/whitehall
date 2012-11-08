require 'csv'

%w(a b c).each do |part|
  path = __FILE__.gsub(/\.rb/, "#{part}.csv")
  error_path = File.basename(path).gsub(/\.csv/, '_errors.csv')
  puts "Processing #{path}"
  data = File.open(path, 'r', encoding: "UTF-8")
  PublicationUploader.new(csv_data: data, error_csv_path: error_path).upload
end
