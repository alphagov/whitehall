desc "uses a given CSV to migrate documents from GDS to CDDO"
task migrate_gds_documents_to_cddo: :environment do
  CSV.foreach(Rails.root.join("lib/tasks/migrate_gds_documents_to_cddo.csv"), headers: true) do |row|
    # HTML attachments belong to parent document
    next if row["Document type"] == "HTML attachment"

    # CSV 'Slug' is a base path without / prefix
    slug = row["Slug"].split("/").last

    # Slugs are the same for different docs and writing generic matching
    # behaviour for the given 'document type' is difficult so this has been
    # hardcoded
    document = case row["Slug"]
               when "government/collections/a-guide-to-using-artificial-intelligence-in-the-public-sector"
                 Document.find_by(slug: slug, document_type: "DocumentCollection")
               when "government/publications/a-guide-to-using-artificial-intelligence-in-the-public-sector"
                 Document.find_by(slug: slug, document_type: "Publication")
               else
                 Document.find_by(slug: slug)
               end

    raise("Document doesn't exist for slug: #{slug}") if document.blank?

    leading_org_slugs = row["New lead organisation"].split(", ")

    # Order lead organisation ids as stated in the CSV
    correctly_ordered_lead_orgs = leading_org_slugs.map do |org_slug|
      Organisation.find_by(slug: org_slug).presence ||
        raise("Organisation does not exist for slug: #{org_slug} (document slug: #{slug})")
    end

    supporting_org_slugs = row["New supporting organisation"]&.split(", ") || []

    # Order supporting organisation ids as stated in the CSV
    correctly_ordered_supporting_orgs = supporting_org_slugs.map do |org_slug|
      Organisation.find_by(slug: org_slug).presence ||
        raise("Organisation does not exist for slug: #{org_slug} (document slug: #{slug})")
    end

    document.editions.where.not(state: "superseded").each do |edition|
      # Destroy existing lead and supporting orgs
      edition.edition_organisations.destroy_all

      # Add new lead and supporting orgs
      edition.lead_organisations = correctly_ordered_lead_orgs
      edition.supporting_organisations = correctly_ordered_supporting_orgs

      # Save changes bypassing change note presence validation errors for certain drafts
      edition.save!(validate: false)
    end

    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing", document.id, true
    )

    puts "Updated and republished document with slug: #{slug}"
  end
end
