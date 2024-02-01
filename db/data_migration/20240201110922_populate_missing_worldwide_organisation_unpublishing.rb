unpublished_cips = CorporateInformationPage.where(state: "unpublished").select { |o| o.unpublishing.nil? }

unpublished_cips.each do |cip|
  Unpublishing.create!(
    edition: cip,
    unpublishing_reason: UnpublishingReason::Consolidated,
    alternative_url: cip.worldwide_organisation.public_url,
    document_type: cip.document.document_type,
    slug: cip.slug,
    redirect: true,
    content_id: cip.document.content_id,
    unpublished_at: cip.versions.where(state: "unpublished").last.created_at,
  )

  PublishingApiDocumentRepublishingWorker.perform_async(cip.document_id)
end
