require 'csv'

CSV.open(Rails.root.join('tmp/child_killing.csv'),'w') do |output|
  output << %w(message document_id source_url)

  CSV.read('db/data_migration/20130315140536_kill_the_children.csv', headers: false, encoding: "UTF-8").each do |row|
    url = row.first

    if source = DocumentSource.where(url: url).first
      if !source.document.latest_edition || source.document.latest_edition.imported?
        output << ["Document is in :import state or has been deleted. Deleting source and document",source.document.id,url]
        source.destroy
        source.document.destroy
      else
        output << ["Warning: Document is in :#{source.document.latest_edition.state} so will not be deleted",source.document.id,url]
      end
    else
      output << ["Warning: DocumentSource not found",nil,url]
    end
  end
end
