# Unpublish guidance/seed-enterprise-investment-scheme-procedures and redirect to guidance/venture-capital-schemes-apply-to-use-the-seed-enterprise-investment-scheme
document_id = 272247
detailed_guide = Document.find(document_id)

if detailed_guide.published_edition
  unpublisher = EditionUnpublisher.new(
    detailed_guide.published_edition,
    unpublishing: {
      unpublishing_reason_id: UnpublishingReason::Consolidated.id,
      explanation: "Unpublished as consolidated into another GOV.UK page. Editorial Board approval received. Redirected.",
      alternative_url: "#{Whitehall.public_protocol}://#{Whitehall.public_host}/guidance/venture-capital-schemes-apply-to-use-the-seed-enterprise-investment-scheme"
    }
  )

  unpublisher.perform!

  PublishingApiDocumentRepublishingWorker.new.perform(document_id)
end
