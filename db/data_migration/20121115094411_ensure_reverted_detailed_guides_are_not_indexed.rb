require 'csv'

# We are explicitly loading the file from the migration that caused the original issue
data = CSV.read(
  File.dirname(__FILE__) + '/20121008103408_revert_detailed_guides_to_draft.csv',
  headers: false)

data.each do |row|
  guide = Document.at_slug(DetailedGuide, row[0])

  next unless guide

  unless guide.published?
    any_edition = Edition.unscoped.where(document_id: guide.id).first
    if any_edition
      puts "Removing guide #{guide.slug} from search index"
      any_edition.remove_from_search_index
    end
  end
end