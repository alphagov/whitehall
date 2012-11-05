data = File.read(__FILE__.gsub(/\.rb/, '.csv'))
ConsultationUploader.new(csv_data: data).upload
