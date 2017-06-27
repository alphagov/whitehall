namespace :worldwide_taxonomy do
  task republish_world_locations: :environment do
    DataHygiene::PublishingApiRepublisher.new(WorldLocation.all).perform
  end

  task redirect_world_location_translations_to_en: :environment do
    base_path_prefix = "/government/world"
    world_locations = WorldLocation.all

    world_locations.each do |world_location|
      en_slug = world_location.slug
      destination_base_path = File.join("", base_path_prefix, en_slug)
      content_id = world_location.content_id
      locales = world_location.original_available_locales - [:en]

      locales.each do |locale|
        PublishingApiRedirectWorker.perform_async_in_queue(
          "bulk_republishing",
          content_id,
          destination_base_path,
          locale
        )
      end
    end
  end

  task republish_the_world: :environment do
    worldwide_organisations = WorldwideOrganisation.all
    corporate_information_pages = CorporateInformationPage
      .joins(:edition_organisation)
      .where(
        "edition_organisations.organisation_id IN (?)",
        worldwide_organisations.map(&:id)
      )

    world_locations = WorldLocation.all

    world_locations.each do |world_location|
      WorldLocationNewsPageWorker.perform_async(world_location)
    end

    [worldwide_organisations, world_locations].each do |collection|
      DataHygiene::PublishingApiRepublisher.new(collection).perform
    end

    corporate_information_page_document_ids = corporate_information_pages.
      pluck(:document_id).uniq
    puts "Queueing #{corporate_information_page_document_ids.count} corporate information pages for republishing"
    corporate_information_page_document_ids.each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id
      )
      print "."
    end
  end
end
