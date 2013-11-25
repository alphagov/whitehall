
class EditionTranslation < ActiveRecord::Base
  belongs_to :edition

  def state
    edition.try(:state) || 'deleted'
  end
end
EditionTranslation.table_name = :edition_translations

require 'bad_markdown_link_cleaner'

cleaner = BadMarkdownLinkCleaner.new(logger: Logger.new(STDOUT))
EditionTranslation.includes(:edition).where("editions.state NOT IN ('deleted', 'superseded', 'archived') AND edition_translations.body LIKE '%[%'").find_each do |et|
  cleaner.clean!(et)
end

csv_dir = Pathname.new('tmp/link_csvs')
csv_dir.mkpath

headers = [:edition, :state, :original, :replacement, :admin_link, :force_published]
cleaner.csv_data.each do |link_type, links|
  csv_path = csv_dir + "#{link_type}.csv"
  puts "Building #{csv_path}"
  File.open(csv_path, 'w') do |file|
    file.puts headers.join(',')

    links.each do |link_data|
      file.puts link_data.slice(*headers).values.join(',')
    end
  end
end