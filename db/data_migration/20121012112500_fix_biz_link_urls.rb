require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: false, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")
PaperTrail.whodunnit = creator

data.each do |row|
  title, _, bis_url, new_url = row

  guide = DetailedGuide.find_by_title(title)

  next unless guide

  guide = guide.latest_edition

  body = guide.body

  if body.include?(bis_url)
    guide = guide.create_draft(creator) if guide.published?
    body = guide.body
    guide.body = body.sub(bis_url, new_url)
    guide.minor_change = true

    if guide.save
      puts "Saved #{title}"
    else
      puts "Problem saving #{title}:"
      p guide.errors
      puts ""
    end
  end

end
