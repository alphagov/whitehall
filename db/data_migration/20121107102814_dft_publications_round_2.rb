data = File.read(__FILE__.gsub(/\.rb/, '.csv'))
PublicationUploader.new(csv_data: data).upload
