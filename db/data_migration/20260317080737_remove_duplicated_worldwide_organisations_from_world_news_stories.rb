editions_with_duplicated_worldwide_organisations = StandardEdition
                             .where(configurable_document_type: "world_news_story")
                             .where.not(state: %w[deleted superseded])
                             .joins(:edition_worldwide_organisations)
                             .select("editions.*, COUNT(edition_worldwide_organisations.document_id) - COUNT(DISTINCT edition_worldwide_organisations.document_id) AS duplicate_count")
                             .group("editions.id")
                             .having("COUNT(edition_worldwide_organisations.document_id) != COUNT(DISTINCT edition_worldwide_organisations.document_id)")

puts "Stats"
puts "------------------------------"
puts "Editions with duplicate worldwide organisations count: #{editions_with_duplicated_worldwide_organisations.pluck(:id).count}"
puts "\nEdition ID | Document ID | Created at"
editions_with_duplicated_worldwide_organisations.map do |e|
  ewwos = e.edition_worldwide_organisations
  ewwos.map { |ewwo| puts "#{ewwo.edition_id} #{ewwo.document_id} #{ewwo.created_at}" }
end
puts "------------------------------"

puts "\nRun"
puts "------------------------------"
editions_with_duplicated_worldwide_organisations.each do |edition|
  ActiveRecord::Base.transaction do
    worldwide_org_document_ids = edition.edition_worldwide_organisations.pluck(:document_id)
    duplicate_document_ids = worldwide_org_document_ids.select { |id| worldwide_org_document_ids.count(id) > 1 }.uniq

    duplicate_document_ids.each do |document_id|
      duplicate_rows = edition.edition_worldwide_organisations.where(document_id:).order(:id)
      rows_to_delete = duplicate_rows.offset(1)
      puts "Edition #{edition.id}: removing #{rows_to_delete.count} duplicate(s) for worldwide org document_id #{document_id}"
      rows_to_delete.destroy_all
    end

    PublishingApiDocumentRepublishingWorker.perform_async(edition.document_id)
    puts "Edition #{edition.id} (document_id: #{edition.document_id}): republished"
  end
end

puts "Done."
