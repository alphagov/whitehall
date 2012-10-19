require 'csv'

data = CSV.read(File.dirname(__FILE__) + '/20121012135700_upload_dft_speeches.csv', headers: true, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")

data.each do |row|
  speech = Speech.find_by_title(row['title'])
  if not speech
    $stderr.puts "Unable to find speech #{row['title']}, skipping"
    next
  end

  begin
    speech.save!
    puts "Updated #{speech.id} - #{speech.title}"
  rescue => e
    $stderr.puts "Unable to save '#{row['title']}' because #{e}"
  end
end
