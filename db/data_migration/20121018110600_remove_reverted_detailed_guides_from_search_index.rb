require 'csv'

data = CSV.read(
  File.dirname(__FILE__) + '/20121008103408_revert_detailed_guides_to_draft.csv',
  headers: false)

user = User.find_by_name("Automatic Data Importer") || return
PaperTrail.enabled = false
data.each do |row|
  guide = Document.at_slug(DetailedGuide, row[0])

  next unless guide

  latest_edition = guide.latest_edition

  next unless latest_edition

  unless latest_edition.published?
    latest_edition.remove_from_search_index
    puts "#{latest_edition.title} - removed from search index"
  end
end
