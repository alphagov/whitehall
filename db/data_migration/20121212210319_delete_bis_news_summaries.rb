DocumentSource.joins(:document).where('url LIKE ?', 'http://news.bis.gov.uk%').each do |doc|
  document = doc.document
  edition = document.published_edition || document.latest_edition
  if edition.summary
    edition.update_column('summary', '')
    puts "Removed summary from '#{edition.title}'"
  end
end
