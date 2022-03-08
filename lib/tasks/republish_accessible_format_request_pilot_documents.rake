desc "Republish all documents with attachments for organisations in accessible format request pilot"
task repubish_docs_with_attachments_for_accessible_format_request_pilot: :environment do
  pilot_emails = %w[alternative.formats@education.gov.uk
                    accessible.formats@dwp.gov.uk
                    publications@dhsc.gov.uk
                    different.format@hmrc.gov.uk
                    gov.uk.publishing@dvsa.gov.uk
                    publications@phe.gov.uk].freeze

  organisations = Organisation.where(alternative_format_contact_email: [pilot_emails])

  organisations.each do |org|
    published_editions_for_org = Edition.latest_published_edition.in_organisation(org)
    puts "Total editions for #{org.slug}: #{published_editions_for_org.count}"
    editions_with_attachments = published_editions_for_org.publicly_visible.where(
      id: Attachment.where(accessible: false, attachable_type: "Edition").select("attachable_id"),
    )
    puts "Enqueueing #{editions_with_attachments.count} editions with attachments for #{org.slug}"
    editions_with_attachments.joins(:document).distinct.pluck("documents.id").each do |document_id|
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
    end
    puts "Finished enqueueing items for #{org.slug}"
  end
end
