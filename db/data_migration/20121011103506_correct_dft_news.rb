require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")
data.each do |row|
  begin
    first_published_at = if row['First published'].present?
      month, day, year = row['First published'].split "/"
      Time.zone.parse("#{year}-#{month}-#{day}")
    end
    matches = NewsArticle.where(title: row['Title'], first_published_at: first_published_at)
    docs = matches.map(&:document).uniq
    if docs.count == 1
      n = docs.first.latest_edition
      n.body = row['Body'] + row['Body continued'].to_s
      n.summary = row['Summary']
      n.save!
      puts "Saved #{n.id}: '#{n.title}'"
    elsif docs.count == 0
      $stderr.puts "Couldn't find '#{row['Title']}'"
    else
      $stderr.puts "Found #{docs.count} instances of '#{row['Title']}'"
    end
  end
end