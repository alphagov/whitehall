data = File.read(__FILE__.gsub(/\.rb/, '.csv'))
NewsArticleUploader.new(csv_data: data).upload
